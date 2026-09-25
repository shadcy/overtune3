#include "dsp/FilterAnalysis.h"
#include <array>
#include <cmath>
#include <numbers>

namespace dsp {

static constexpr double PI = std::numbers::pi;

// Apply filter biquad cascade to a single sample (Direct Form II Transposed)
static double biquadProcess(const FilterCoefficients& c,
                             std::vector<std::array<double,2>>& state,
                             double x) {
    double y = x * c.gain;
    for (size_t i = 0; i < c.sos.size(); ++i) {
        const auto& s = c.sos[i];
        const double w = y - s.a1 * state[i][0] - s.a2 * state[i][1];
        const double out = s.b0 * w + s.b1 * state[i][0] + s.b2 * state[i][1];
        state[i][1] = state[i][0];
        state[i][0] = w;
        y = out;
    }
    return y;
}

AnalysisResult FilterAnalysis::compute(const FilterCoefficients& coeff,
                                       double sampleRate,
                                       int    numPoints) {
    AnalysisResult result;
    result.poles = coeff.poles;
    result.zeros = coeff.zeros;
    result.gain  = coeff.gain;

    const double nyquist = sampleRate / 2.0;
    result.frequencyResponse.resize(numPoints);

    // Phase delay buffer for group delay computation
    const double dOmega = 1e-5;

    for (int i = 0; i < numPoints; ++i) {
        // Log-spaced from 1 Hz to Nyquist
        const double freq = std::pow(10.0,
            std::log10(1.0) + (std::log10(nyquist) - std::log10(1.0)) *
            static_cast<double>(i) / static_cast<double>(numPoints - 1));

        const double omega = 2.0 * PI * freq / sampleRate;

        const Complex H  = coeff.evaluate(omega);
        const Complex Hd = coeff.evaluate(omega + dOmega);

        const double mag   = std::abs(H);
        const double magDb = mag > 1e-300 ? 20.0 * std::log10(mag) : -300.0;
        const double phase = std::arg(H) * 180.0 / PI;

        // Group delay = -d(phase)/dω  (in samples)
        double phaseH  = std::arg(H);
        double phaseHd = std::arg(Hd);
        // Unwrap
        while (phaseHd - phaseH >  PI) phaseHd -= 2 * PI;
        while (phaseHd - phaseH < -PI) phaseHd += 2 * PI;
        const double gd = -(phaseHd - phaseH) / dOmega;

        result.frequencyResponse[i] = { freq, magDb, phase, gd };
    }

    result.impulseResponse = impulseResponse(coeff);
    result.stepResponse    = stepResponse(coeff);

    return result;
}

std::vector<double> FilterAnalysis::impulseResponse(const FilterCoefficients& coeff, int length) {
    std::vector<std::array<double,2>> state(coeff.sos.size(), {0.0, 0.0});
    std::vector<double> out(length);
    for (int i = 0; i < length; ++i)
        out[i] = biquadProcess(coeff, state, i == 0 ? 1.0 : 0.0);
    return out;
}

std::vector<double> FilterAnalysis::stepResponse(const FilterCoefficients& coeff, int length) {
    std::vector<std::array<double,2>> state(coeff.sos.size(), {0.0, 0.0});
    std::vector<double> out(length);
    for (int i = 0; i < length; ++i)
        out[i] = biquadProcess(coeff, state, 1.0);
    return out;
}

} // namespace dsp
