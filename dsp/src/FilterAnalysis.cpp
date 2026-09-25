#include "dsp/FilterAnalysis.h"
#include <array>
#include <cmath>
#include <numbers>
#include <algorithm>

namespace dsp {

static constexpr double PI = std::numbers::pi;

// Apply filter biquad cascade to a single sample (Direct Form II Canonical)
static double biquadProcess(const FilterCoefficients& c,
                             std::vector<std::array<double,2>>& state,
                             double x) {
    double y = x * c.gain;
    for (size_t i = 0; i < c.sos.size(); ++i) {
        const auto& s = c.sos[i];
        const double w   = y - s.a1 * state[i][0] - s.a2 * state[i][1];
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

    double unwrappedPhase = 0.0;
    double prevRawPhase   = 0.0;

    for (int i = 0; i < numPoints; ++i) {
        // Logarithmically spaced frequencies from 1 Hz to Nyquist
        const double frac = static_cast<double>(i) / static_cast<double>(numPoints - 1);
        const double freq = std::pow(10.0,
            std::log10(1.0) + (std::log10(nyquist) - std::log10(1.0)) * frac);

        const double omega = 2.0 * PI * freq / sampleRate;
        const Complex z    = std::polar(1.0, omega);
        const Complex zInv = 1.0 / z;
        const Complex zInv2 = zInv * zInv;

        const Complex H = coeff.evaluate(omega);
        const double mag = std::abs(H);
        const double magDb = mag > 1e-15 ? 20.0 * std::log10(mag) : -300.0;

        // Smooth continuous phase unwrapping across frequency sweep
        const double rawPhase = std::arg(H);
        if (i == 0) {
            unwrappedPhase = rawPhase;
        } else {
            double dP = rawPhase - prevRawPhase;
            while (dP > PI)  dP -= 2.0 * PI;
            while (dP < -PI) dP += 2.0 * PI;
            unwrappedPhase += dP;
        }
        prevRawPhase = rawPhase;
        const double phaseDeg = unwrappedPhase * 180.0 / PI;

        // Exact analytical group delay: \tau_g(\omega) = \sum \tau_{g,k}(\omega)
        double totalGd = 0.0;
        for (const auto& s : coeff.sos) {
            const Complex num = s.b0 + s.b1 * zInv + s.b2 * zInv2;
            const Complex den = 1.0  + s.a1 * zInv + s.a2 * zInv2;
            if (std::abs(num) > 1e-12) {
                const Complex numDeriv = (s.b1 * zInv + 2.0 * s.b2 * zInv2) / num;
                totalGd += numDeriv.real();
            }
            if (std::abs(den) > 1e-12) {
                const Complex denDeriv = (s.a1 * zInv + 2.0 * s.a2 * zInv2) / den;
                totalGd -= denDeriv.real();
            }
        }

        result.frequencyResponse[i] = { freq, magDb, phaseDeg, totalGd };
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
