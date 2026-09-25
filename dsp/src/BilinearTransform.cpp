#include "BilinearTransform.h"
#include <cmath>
#include <algorithm>
#include <numbers>
#include <vector>

namespace dsp::internal {

static constexpr double PI = std::numbers::pi;

double prewarp(double freqHz, double sampleRate) noexcept {
    return 2.0 * sampleRate * std::tan(PI * freqHz / sampleRate);
}

// Map analog s-plane root to digital z-plane using bilinear transform:
// s = 2*Fs * (z - 1) / (z + 1)  ==>  z = (2*Fs + s) / (2*Fs - s)
static Complex sToZ(Complex s, double fs) {
    const Complex k{2.0 * fs};
    return (k + s) / (k - s);
}

struct SectionPair {
    Complex r1{0.0, 0.0};
    Complex r2{0.0, 0.0};
    bool isSecondOrder{true};
};

// Group roots (poles or zeros) into conjugate pairs and real pairs
static std::vector<SectionPair> pairRoots(const ComplexVec& roots) {
    std::vector<SectionPair> pairs;
    std::vector<Complex> realRoots;
    std::vector<Complex> compRoots;

    for (const auto& r : roots) {
        if (std::abs(r.imag()) < 1e-9) {
            realRoots.push_back(Complex{r.real(), 0.0});
        } else {
            compRoots.push_back(r);
        }
    }

    // Pair complex conjugate roots
    std::vector<bool> compUsed(compRoots.size(), false);
    for (size_t i = 0; i < compRoots.size(); ++i) {
        if (compUsed[i]) continue;
        int bestJ = -1;
        double minDiff = 1e9;
        for (size_t j = i + 1; j < compRoots.size(); ++j) {
            if (compUsed[j]) continue;
            // Best conjugate match: real parts equal, imag parts opposite
            const double diff = std::abs(compRoots[i].real() - compRoots[j].real()) +
                                std::abs(compRoots[i].imag() + compRoots[j].imag());
            if (diff < minDiff) {
                minDiff = diff;
                bestJ = static_cast<int>(j);
            }
        }

        if (bestJ >= 0 && minDiff < 1e-4) {
            compUsed[i] = true;
            compUsed[bestJ] = true;
            // Pick positive imaginary part as r1
            Complex c1 = compRoots[i].imag() > 0 ? compRoots[i] : compRoots[bestJ];
            Complex c2 = std::conj(c1);
            pairs.push_back({c1, c2, true});
        } else {
            // Unpaired complex: treat as self-conjugate
            compUsed[i] = true;
            pairs.push_back({compRoots[i], std::conj(compRoots[i]), true});
        }
    }

    // Sort real roots ascending
    std::sort(realRoots.begin(), realRoots.end(), [](const Complex& a, const Complex& b) {
        return a.real() < b.real();
    });

    // Pair real roots in pairs of two
    for (size_t i = 0; i + 1 < realRoots.size(); i += 2) {
        pairs.push_back({realRoots[i], realRoots[i + 1], true});
    }
    // Odd real root left over
    if (realRoots.size() % 2 == 1) {
        pairs.push_back({realRoots.back(), Complex{0.0, 0.0}, false});
    }

    return pairs;
}

FilterCoefficients bilinearTransform(const ComplexVec& analogPoles,
                                     const ComplexVec& analogZeros,
                                     double            analogGain,
                                     const FilterSpec& spec) {
    const double fs = spec.sampleRate;
    const double wc = prewarp(spec.cutoffFreq, fs);
    const double wc2 = (spec.type == FilterType::BandPass ||
                        spec.type == FilterType::BandStop)
                     ? prewarp(spec.cutoffFreq2, fs) : 0.0;

    // Step 1: Scale analog prototype poles to target band
    ComplexVec sPoles;
    auto scalePole = [&](Complex p) -> ComplexVec {
        switch (spec.type) {
            case FilterType::LowPass:
                return { p * wc };
            case FilterType::HighPass:
                return { Complex{wc} / p };
            case FilterType::BandPass: {
                const double bw = std::max(1e-6, wc2 - wc);
                const double w02 = wc * wc2;
                const Complex a = p * (bw / 2.0);
                const Complex sq = std::sqrt(a * a - Complex{w02});
                return { a + sq, a - sq };
            }
            case FilterType::BandStop: {
                const double bw = std::max(1e-6, wc2 - wc);
                const double w02 = wc * wc2;
                const Complex a = Complex{bw / 2.0} / p;
                const Complex sq = std::sqrt(a * a - Complex{w02});
                return { a + sq, a - sq };
            }
        }
        return { p * wc };
    };

    for (const auto& p : analogPoles) {
        for (const auto& sp : scalePole(p)) {
            sPoles.push_back(sp);
        }
    }

    // Step 2: Map analog zeros to s-plane
    ComplexVec sZeros;
    for (const auto& z : analogZeros) {
        for (const auto& sz : scalePole(z)) {
            sZeros.push_back(sz);
        }
    }

    // Step 3: Bilinear transform s -> z for finite roots
    ComplexVec zPoles;
    zPoles.reserve(sPoles.size());
    for (const auto& p : sPoles) {
        zPoles.push_back(sToZ(p, fs));
    }

    ComplexVec zZeros;
    zZeros.reserve(sPoles.size());
    for (const auto& z : sZeros) {
        zZeros.push_back(sToZ(z, fs));
    }

    // Step 4: Place zeros for zeros at infinity according to filter topology:
    // - LowPass: zeros at s = infinity map to z = -1
    // - HighPass: zeros at s = infinity map to s = 0, which maps to z = +1
    // - BandPass: N zeros at z = +1, N zeros at z = -1
    // - BandStop: 2N zeros at z = e^{\pm j \omega_0 T}
    if (spec.type == FilterType::LowPass) {
        while (zZeros.size() < zPoles.size()) {
            zZeros.push_back(Complex{-1.0, 0.0});
        }
    } else if (spec.type == FilterType::HighPass) {
        while (zZeros.size() < zPoles.size()) {
            zZeros.push_back(Complex{1.0, 0.0});
        }
    } else if (spec.type == FilterType::BandPass) {
        // Prototype zeros at infinity produce equal counts of z = +1 and z = -1 zeros
        const size_t needed = zPoles.size() > zZeros.size() ? (zPoles.size() - zZeros.size()) : 0;
        const size_t half = needed / 2;
        for (size_t i = 0; i < half; ++i) {
            zZeros.push_back(Complex{1.0, 0.0});
            zZeros.push_back(Complex{-1.0, 0.0});
        }
        if (needed % 2 == 1) {
            zZeros.push_back(Complex{1.0, 0.0});
        }
    } else if (spec.type == FilterType::BandStop) {
        // Prototype zeros at infinity produce zeros at s = \pm j w0
        const double w0 = std::sqrt(wc * wc2);
        const Complex zStopPos = sToZ(Complex{0.0,  w0}, fs);
        const Complex zStopNeg = sToZ(Complex{0.0, -w0}, fs);
        while (zZeros.size() + 1 < zPoles.size()) {
            zZeros.push_back(zStopPos);
            zZeros.push_back(zStopNeg);
        }
        if (zZeros.size() < zPoles.size()) {
            zZeros.push_back(zStopPos);
        }
    }

    // Step 5: Rigorously pair poles and zeros into biquads
    auto polePairs = pairRoots(zPoles);
    auto zeroPairs = pairRoots(zZeros);

    // Sort pole pairs in ascending order of radius (lowest Q first for dynamic range)
    std::sort(polePairs.begin(), polePairs.end(), [](const SectionPair& a, const SectionPair& b) {
        const double magA = std::abs(a.r1);
        const double magB = std::abs(b.r1);
        return magA < magB;
    });

    // Match each pole pair with the best zero pair
    std::vector<bool> zeroUsed(zeroPairs.size(), false);
    FilterCoefficients out;
    out.poles = zPoles;
    out.zeros = zZeros;
    out.gain  = 1.0;

    for (const auto& pp : polePairs) {
        int bestZ = -1;
        double minDist = 1e9;
        for (size_t j = 0; j < zeroPairs.size(); ++j) {
            if (zeroUsed[j]) continue;
            // Match 2nd order with 2nd order, 1st with 1st
            if (zeroPairs[j].isSecondOrder != pp.isSecondOrder) continue;
            const double d = std::abs(pp.r1 - zeroPairs[j].r1);
            if (d < minDist) {
                minDist = d;
                bestZ = static_cast<int>(j);
            }
        }
        // Fallback to any unused zero pair if order match fails
        if (bestZ < 0) {
            for (size_t j = 0; j < zeroPairs.size(); ++j) {
                if (!zeroUsed[j]) {
                    bestZ = static_cast<int>(j);
                    break;
                }
            }
        }

        Biquad b;
        b.a0 = 1.0;
        if (pp.isSecondOrder) {
            b.a1 = -(pp.r1 + pp.r2).real();
            b.a2 =  (pp.r1 * pp.r2).real();
        } else {
            b.a1 = -pp.r1.real();
            b.a2 =  0.0;
        }

        if (bestZ >= 0) {
            zeroUsed[bestZ] = true;
            const auto& zp = zeroPairs[bestZ];
            b.b0 = 1.0;
            if (zp.isSecondOrder) {
                b.b1 = -(zp.r1 + zp.r2).real();
                b.b2 =  (zp.r1 * zp.r2).real();
            } else {
                b.b1 = -zp.r1.real();
                b.b2 =  0.0;
            }
        } else {
            // Default unity numerator if no matching zero
            b.b0 = 1.0; b.b1 = 0.0; b.b2 = 0.0;
        }

        out.sos.push_back(b);
    }

    // Step 6: Exact Gain Normalisation
    // Evaluate H(z) at a reference frequency in the passband
    double targetOmega = 0.0;
    if (spec.type == FilterType::HighPass) {
        targetOmega = PI; // Nyquist
    } else if (spec.type == FilterType::BandPass) {
        const double f0 = std::sqrt(spec.cutoffFreq * spec.cutoffFreq2);
        targetOmega = 2.0 * PI * f0 / fs;
        if (targetOmega >= PI) targetOmega = PI * 0.99;
    } else if (spec.type == FilterType::BandStop) {
        targetOmega = 0.0; // DC
    } else {
        targetOmega = 0.0; // LowPass at DC
    }

    // Target magnitude
    double targetMag = analogGain;
    if (spec.response == FilterResponse::ChebyshevI && (spec.order % 2 == 0) &&
        spec.type == FilterType::LowPass) {
        // Even-order Chebyshev I has ripple at DC: |H(0)| = 10^(-Rp/20)
        targetMag = analogGain * std::pow(10.0, -spec.rippleDb / 20.0);
    }

    Complex H{1.0};
    const Complex zRef = std::polar(1.0, targetOmega);
    for (const auto& s : out.sos) {
        const Complex num = s.b0 + s.b1 / zRef + s.b2 / (zRef * zRef);
        const Complex den = 1.0  + s.a1 / zRef + s.a2 / (zRef * zRef);
        if (std::abs(den) > 1e-300) {
            H *= num / den;
        }
    }

    const double mag = std::abs(H);
    if (mag > 1e-15) {
        out.gain = targetMag / mag;
    } else {
        out.gain = 1.0;
    }

    return out;
}

} // namespace dsp::internal
