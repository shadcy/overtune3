#include "BilinearTransform.h"
#include <cmath>
#include <cassert>
#include <numbers>

namespace dsp::internal {

static constexpr double PI = std::numbers::pi;

double prewarp(double freqHz, double sampleRate) noexcept {
    return 2.0 * sampleRate * std::tan(PI * freqHz / sampleRate);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: convert a list of s-domain poles/zeros + gain to z-domain SOS
// using the bilinear transform:   s = 2*Fs*(z-1)/(z+1)
// ─────────────────────────────────────────────────────────────────────────────
static Complex sToZ(Complex s, double fs) {
    // z = (1 + s/(2*fs)) / (1 - s/(2*fs))
    const Complex k{2.0 * fs};
    return (k + s) / (k - s);
}

// Build one biquad from two z-domain poles (and optional zeros).
// If fewer than two poles/zeros are provided, they are padded to z = ±1.
static Biquad makeBiquad(Complex z1, Complex z2, Complex p1, Complex p2, double g) {
    // b coefficients from zeros
    // (z - z1)(z - z2) = z^2 - (z1+z2)*z + z1*z2
    const double sb0 = g;
    const double sb1 = -g * (z1 + z2).real();
    const double sb2 =  g * (z1 * z2).real();
    // a coefficients from poles
    const double sa1 = -(p1 + p2).real();
    const double sa2 =  (p1 * p2).real();
    return Biquad{ sb0, sb1, sb2, 1.0, sa1, sa2 };
}

FilterCoefficients bilinearTransform(const ComplexVec& analogPoles,
                                     const ComplexVec& analogZeros,
                                     double            analogGain,
                                     const FilterSpec& spec) {
    const double fs = spec.sampleRate;
    const double wc = prewarp(spec.cutoffFreq, fs);   // primary cutoff (rad/s)
    const double wc2 = (spec.type == FilterType::BandPass ||
                        spec.type == FilterType::BandStop)
                     ? prewarp(spec.cutoffFreq2, fs) : 0.0;

    // Step 1: frequency-scale the prototype poles/zeros
    ComplexVec scaledPoles = analogPoles;
    ComplexVec scaledZeros = analogZeros;

    auto scalePole = [&](Complex p) -> ComplexVec {
        switch (spec.type) {
            case FilterType::LowPass:
                return { p * wc };
            case FilterType::HighPass:
                return { wc / p };
            case FilterType::BandPass: {
                // LPF → BPF: p → p*BW/2 ± sqrt((p*BW/2)^2 - wc*wc2)
                const double bw = wc2 - wc;
                const double w0 = std::sqrt(wc * wc2);
                const Complex a = p * (bw / 2.0);
                const Complex disc = a*a - Complex{w0*w0};
                const Complex sq = std::sqrt(disc);
                return { a + sq, a - sq };
            }
            case FilterType::BandStop: {
                const double bw = wc2 - wc;
                const double w0 = std::sqrt(wc * wc2);
                // LPF → BSF: p → (bw/2) / p ± ...
                const Complex a = Complex{bw / 2.0} / p;
                const Complex disc = a*a - Complex{w0*w0};
                const Complex sq = std::sqrt(disc);
                return { a + sq, a - sq };
            }
        }
        return { p * wc };
    };

    // Build frequency-scaled s-domain poles
    ComplexVec sPoles, sZeros;
    for (auto& p : analogPoles)
        for (auto& pp : scalePole(p))
            sPoles.push_back(pp);

    // Zeros: analog LPF prototype has zeros at infinity; after band transforms add finite zeros
    for (auto& z : analogZeros)
        for (auto& zz : scalePole(z))
            sZeros.push_back(zz);

    // Band transforms double the order; add zeros at +/-j*w0 for BPF, at origin for BPF
    if (spec.type == FilterType::BandPass) {
        // N zeros added at s=0 (one per LPF pole mapped)
        for (size_t i = 0; i < analogPoles.size(); ++i)
            sZeros.push_back(Complex{0.0});
    }
    if (spec.type == FilterType::BandStop) {
        const double w0 = std::sqrt(prewarp(spec.cutoffFreq, fs) * prewarp(spec.cutoffFreq2, fs));
        for (size_t i = 0; i < analogPoles.size(); ++i) {
            sZeros.push_back(Complex{ 0.0,  w0 });
            sZeros.push_back(Complex{ 0.0, -w0 });
        }
    }

    // Step 2: bilinear transform s → z
    ComplexVec zPoles, zZeros;
    zPoles.reserve(sPoles.size());
    zZeros.reserve(sZeros.size());
    for (auto& p : sPoles) zPoles.push_back(sToZ(p, fs));
    for (auto& z : sZeros) zZeros.push_back(sToZ(z, fs));

    // Pad zeros to match pole count (remaining zeros at z = -1)
    while (zZeros.size() < zPoles.size())
        zZeros.push_back(Complex{-1.0});

    // Step 3: pack into biquad sections
    const int n = static_cast<int>(zPoles.size());

    // Compute overall gain correction so H(z=1) = analogGain (magnitude at DC for LPF)
    // We'll normalise afterwards.
    FilterCoefficients out;
    out.gain   = 1.0;
    out.poles  = zPoles;
    out.zeros  = zZeros;

    for (int i = 0; i + 1 < n; i += 2) {
        Biquad b = makeBiquad(zZeros[i], zZeros[i+1], zPoles[i], zPoles[i+1], 1.0);
        out.sos.push_back(b);
    }
    if (n % 2 == 1) {
        // Odd order: one first-order section promoted to biquad with z=-1 zero
        const int i = n - 1;
        Biquad b = makeBiquad(zZeros[i], Complex{-1.0}, zPoles[i], Complex{0.0}, 1.0);
        out.sos.push_back(b);
    }

    // Gain normalisation — evaluate H at ω=0 (DC) or ω=π and set gain
    // to achieve unity at the passband edge.
    {
        double targetOmega = 0.0;
        if (spec.type == FilterType::HighPass) targetOmega = PI;
        else if (spec.type == FilterType::BandPass)
            targetOmega = PI * std::sqrt(spec.cutoffFreq * spec.cutoffFreq2) / (fs / 2.0);

        Complex H{1.0};
        for (auto& s : out.sos) {
            const Complex z = std::polar(1.0, targetOmega);
            const Complex num = s.b0 + s.b1 / z + s.b2 / (z * z);
            const Complex den = 1.0  + s.a1 / z + s.a2 / (z * z);
            if (std::abs(den) > 1e-300) H *= num / den;
        }
        const double mag = std::abs(H);
        if (mag > 1e-300) out.gain = analogGain / mag;
    }

    return out;
}

} // namespace dsp::internal
