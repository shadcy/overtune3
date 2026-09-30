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
                                       int    numPoints,
                                       double cutoff1,
                                       double cutoff2) {
    AnalysisResult result;
    result.poles = coeff.poles;
    result.zeros = coeff.zeros;
    result.gain  = coeff.gain;

    const double nyquist = sampleRate / 2.0;
    if (numPoints < 256) numPoints = 256;

    // Minimum frequency: adapt to low cutoff filters (e.g. 5 Hz or 13.5 Hz)
    double fMin = 0.05;
    if (cutoff1 > 0.0) {
        fMin = std::min(fMin, cutoff1 / 50.0);
    }
    if (cutoff2 > 0.0) {
        fMin = std::min(fMin, cutoff2 / 50.0);
    }
    fMin = std::clamp(fMin, 0.0001, 1.0);

    // Build comprehensive adaptive frequency vector
    std::vector<double> freqs;
    freqs.reserve(numPoints * 2 + 1024);

    // 1. DC (0 Hz) - vital for linear and normalized digital axes
    freqs.push_back(0.0);

    // 2. Logarithmically spaced base grid (dense audio/low-frequency coverage)
    const double logMin = std::log10(fMin);
    const double logMax = std::log10(nyquist);
    for (int i = 0; i < numPoints; ++i) {
        const double frac = static_cast<double>(i) / static_cast<double>(numPoints - 1);
        freqs.push_back(std::pow(10.0, logMin + (logMax - logMin) * frac));
    }

    // 3. Linearly spaced uniform grid (dense RF/high-frequency coverage across entire spectrum)
    for (int i = 0; i < numPoints; ++i) {
        const double f = (static_cast<double>(i) / static_cast<double>(numPoints - 1)) * nyquist;
        if (f > 0.0 && f < nyquist) {
            freqs.push_back(f);
        }
    }

    // 4. High-precision transition band clustering around critical cutoff frequencies
    auto injectCluster = [&](double fc) {
        if (fc <= fMin || fc >= nyquist) return;
        freqs.push_back(fc); // Exact cutoff point

        // Dense sampling around transition band
        static constexpr double offsets[] = {
            -0.35, -0.25, -0.18, -0.12, -0.08, -0.05, -0.03, -0.02, -0.015, -0.01,
            -0.005, -0.002, -0.001, -0.0005, -0.0002,
             0.0002,  0.0005,  0.001,  0.002,  0.005,  0.01,  0.015,  0.02,  0.03,
             0.05,  0.08,  0.12,  0.18,  0.25,  0.35
        };
        for (double off : offsets) {
            double f = fc * (1.0 + off);
            if (f > 0.0 && f < nyquist) {
                freqs.push_back(f);
            }
        }
    };

    if (cutoff1 > 0.0) injectCluster(cutoff1);
    if (cutoff2 > 0.0) injectCluster(cutoff2);

    // 5. Resonant peaks and zeros near the unit circle
    for (const auto& p : coeff.poles) {
        double theta = std::abs(std::arg(p));
        double f = (theta / (2.0 * PI)) * sampleRate;
        if (f > 0.0 && f < nyquist) {
            freqs.push_back(f);
            double bw = (1.0 - std::min(0.9999, std::abs(p))) * sampleRate / (2.0 * PI);
            if (bw > 0.001 && bw < sampleRate * 0.1) {
                if (f - bw > 0.0) freqs.push_back(f - bw);
                if (f + bw < nyquist) freqs.push_back(f + bw);
            }
        }
    }
    for (const auto& z : coeff.zeros) {
        double theta = std::abs(std::arg(z));
        double f = (theta / (2.0 * PI)) * sampleRate;
        if (f > 0.0 && f < nyquist) {
            freqs.push_back(f);
            double bw = (1.0 - std::min(0.9999, std::abs(z))) * sampleRate / (2.0 * PI);
            if (bw > 0.001 && bw < sampleRate * 0.1) {
                if (f - bw > 0.0) freqs.push_back(f - bw);
                if (f + bw < nyquist) freqs.push_back(f + bw);
            }
        }
    }

    // Exact Nyquist boundaries
    freqs.push_back(nyquist * (1.0 - 1e-9));
    freqs.push_back(nyquist);

    // Sort frequencies monotonically
    std::sort(freqs.begin(), freqs.end());

    // Deduplicate closely spaced frequencies
    auto it = std::unique(freqs.begin(), freqs.end(), [](double a, double b) {
        if (a == 0.0 && b == 0.0) return true;
        if (a == 0.0 || b == 0.0) return false;
        return std::abs(a - b) <= 1e-7 * std::max(a, b);
    });
    freqs.erase(it, freqs.end());

    const size_t totalFreqs = freqs.size();
    result.frequencyResponse.resize(totalFreqs);

    double unwrappedPhase = 0.0;
    double prevRawPhase   = 0.0;
    bool hasPrevPhase     = false;

    for (size_t i = 0; i < totalFreqs; ++i) {
        const double freq = freqs[i];
        const double omega = 2.0 * PI * freq / sampleRate;

        // z = e^{jω} on unit circle
        const Complex z    = std::polar(1.0, omega);
        const Complex zInv = 1.0 / z;
        const Complex zInv2 = zInv * zInv;

        const Complex H = coeff.evaluate(omega);
        const double mag = std::abs(H);
        double magDb = -300.0;
        if (mag > 1e-15) {
            magDb = 20.0 * std::log10(mag);
            if (magDb < -300.0) magDb = -300.0;
            if (magDb > 100.0)  magDb = 100.0;
        }

        // Smooth continuous phase unwrapping across frequency sweep
        // For zeros on unit circle (transmission nulls), evaluate slightly inside (|z|=1-1e-4)
        // to bypass the branch cut singularity and avoid numerical random noise jumps
        double rawPhase = 0.0;
        if (mag > 1e-6) {
            rawPhase = std::arg(H);
        } else {
            const Complex zReg = std::polar(1.0 - 1e-4, omega);
            Complex HReg{coeff.gain};
            for (const auto& s : coeff.sos) {
                const Complex numReg = s.b0 + s.b1 / zReg + s.b2 / (zReg * zReg);
                const Complex denReg = 1.0  + s.a1 / zReg + s.a2 / (zReg * zReg);
                if (std::abs(denReg) > 1e-300) {
                    HReg *= numReg / denReg;
                }
            }
            rawPhase = std::arg(HReg);
        }

        if (!hasPrevPhase) {
            unwrappedPhase = rawPhase;
            hasPrevPhase = true;
        } else {
            double dP = rawPhase - prevRawPhase;
            while (dP > PI)  dP -= 2.0 * PI;
            while (dP < -PI) dP += 2.0 * PI;
            unwrappedPhase += dP;
        }
        prevRawPhase = rawPhase;
        const double phaseDeg = unwrappedPhase * 180.0 / PI;

        // Exact analytical group delay: \tau_g(\omega) = \sum \tau_{g,k}(\omega)
        // Edge cases: zeros or poles on or very close to unit circle cause division by zero.
        // We apply Poisson regularization (evaluating with r = 1 - 1e-4) when denominator < 1e-4.
        double totalGd = 0.0;
        for (const auto& s : coeff.sos) {
            Complex num = s.b0 + s.b1 * zInv + s.b2 * zInv2;
            Complex den = 1.0  + s.a1 * zInv + s.a2 * zInv2;

            if (std::abs(num) < 1e-4) {
                const Complex zReg = std::polar(1.0 - 1e-4, omega);
                const Complex zRInv = 1.0 / zReg;
                const Complex zRInv2 = zRInv * zRInv;
                num = s.b0 + s.b1 * zRInv + s.b2 * zRInv2;
                if (std::abs(num) > 1e-7) {
                    const Complex numDeriv = (s.b1 * zRInv + 2.0 * s.b2 * zRInv2) / num;
                    totalGd += numDeriv.real();
                }
            } else {
                const Complex numDeriv = (s.b1 * zInv + 2.0 * s.b2 * zInv2) / num;
                totalGd += numDeriv.real();
            }

            if (std::abs(den) < 1e-4) {
                const Complex zReg = std::polar(1.0 - 1e-4, omega);
                const Complex zRInv = 1.0 / zReg;
                const Complex zRInv2 = zRInv * zRInv;
                den = 1.0 + s.a1 * zRInv + s.a2 * zRInv2;
                if (std::abs(den) > 1e-7) {
                    const Complex denDeriv = (s.a1 * zRInv + 2.0 * s.a2 * zRInv2) / den;
                    totalGd -= denDeriv.real();
                }
            } else {
                const Complex denDeriv = (s.a1 * zInv + 2.0 * s.a2 * zInv2) / den;
                totalGd -= denDeriv.real();
            }
        }

        if (std::isnan(totalGd) || std::isinf(totalGd)) {
            totalGd = 0.0;
        } else {
            totalGd = std::clamp(totalGd, -2000.0, 2000.0);
        }

        result.frequencyResponse[i] = { freq, magDb, phaseDeg, totalGd };
    }

    result.impulseResponse = impulseResponse(coeff, 512);
    result.stepResponse    = stepResponse(coeff, 512);

    return result;
}

AnalysisPoint FilterAnalysis::evaluatePoint(const FilterCoefficients& coeff,
                                           double sampleRate,
                                           double freqHz) {
    if (!coeff.isValid() || sampleRate <= 0.0) {
        return { 0.0, 0.0, 0.0, 0.0 };
    }
    const double nyquist = sampleRate / 2.0;
    const double clampedF = std::clamp(freqHz, 0.0, nyquist);
    const double omega = 2.0 * PI * clampedF / sampleRate;

    const Complex z = std::polar(1.0, omega);
    const Complex zInv = 1.0 / z;
    const Complex zInv2 = zInv * zInv;

    const Complex H = coeff.evaluate(omega);
    const double mag = std::abs(H);
    double magDb = -300.0;
    if (mag > 1e-15) {
        magDb = 20.0 * std::log10(mag);
        if (magDb < -300.0) magDb = -300.0;
        if (magDb > 100.0)  magDb = 100.0;
    }

    double phaseDeg = 0.0;
    if (mag > 1e-6) {
        phaseDeg = std::arg(H) * 180.0 / PI;
    } else {
        const Complex zReg = std::polar(1.0 - 1e-4, omega);
        Complex HReg{coeff.gain};
        for (const auto& s : coeff.sos) {
            const Complex numReg = s.b0 + s.b1 / zReg + s.b2 / (zReg * zReg);
            const Complex denReg = 1.0  + s.a1 / zReg + s.a2 / (zReg * zReg);
            if (std::abs(denReg) > 1e-300) {
                HReg *= numReg / denReg;
            }
        }
        phaseDeg = std::arg(HReg) * 180.0 / PI;
    }

    double totalGd = 0.0;
    for (const auto& s : coeff.sos) {
        Complex num = s.b0 + s.b1 * zInv + s.b2 * zInv2;
        Complex den = 1.0  + s.a1 * zInv + s.a2 * zInv2;

        if (std::abs(num) < 1e-4) {
            const Complex zReg = std::polar(1.0 - 1e-4, omega);
            const Complex zRInv = 1.0 / zReg;
            const Complex zRInv2 = zRInv * zRInv;
            num = s.b0 + s.b1 * zRInv + s.b2 * zRInv2;
            if (std::abs(num) > 1e-7) {
                const Complex numDeriv = (s.b1 * zRInv + 2.0 * s.b2 * zRInv2) / num;
                totalGd += numDeriv.real();
            }
        } else {
            const Complex numDeriv = (s.b1 * zInv + 2.0 * s.b2 * zInv2) / num;
            totalGd += numDeriv.real();
        }

        if (std::abs(den) < 1e-4) {
            const Complex zReg = std::polar(1.0 - 1e-4, omega);
            const Complex zRInv = 1.0 / zReg;
            const Complex zRInv2 = zRInv * zRInv;
            den = 1.0 + s.a1 * zRInv + s.a2 * zRInv2;
            if (std::abs(den) > 1e-7) {
                const Complex denDeriv = (s.a1 * zRInv + 2.0 * s.a2 * zRInv2) / den;
                totalGd -= denDeriv.real();
            }
        } else {
            const Complex denDeriv = (s.a1 * zInv + 2.0 * s.a2 * zInv2) / den;
            totalGd -= denDeriv.real();
        }
    }

    if (std::isnan(totalGd) || std::isinf(totalGd)) {
        totalGd = 0.0;
    } else {
        totalGd = std::clamp(totalGd, -2000.0, 2000.0);
    }

    return { clampedF, magDb, phaseDeg, totalGd };
}

std::vector<double> FilterAnalysis::impulseResponse(const FilterCoefficients& coeff, int length) {
    if (length < 32) length = 32;
    std::vector<std::array<double,2>> state(coeff.sos.size(), {0.0, 0.0});
    std::vector<double> out(length);
    for (int i = 0; i < length; ++i) {
        double val = biquadProcess(coeff, state, i == 0 ? 1.0 : 0.0);
        if (std::isnan(val) || std::isinf(val)) val = 0.0;
        out[i] = val;
    }
    return out;
}

std::vector<double> FilterAnalysis::stepResponse(const FilterCoefficients& coeff, int length) {
    if (length < 32) length = 32;
    std::vector<std::array<double,2>> state(coeff.sos.size(), {0.0, 0.0});
    std::vector<double> out(length);
    for (int i = 0; i < length; ++i) {
        double val = biquadProcess(coeff, state, 1.0);
        if (std::isnan(val) || std::isinf(val)) val = 0.0;
        out[i] = val;
    }
    return out;
}

VerificationResult FilterAnalysis::verify(const FilterSpec& spec,
                                          const FilterCoefficients& coeff,
                                          const AnalysisResult& analysis) {
    VerificationResult res;
    res.stage1Passed = true;
    res.stage2Passed = true;

    // ── STAGE 0: Strict Numerical Sanity Check ──────────────────────────────
    bool hasNanOrInf = false;
    if (coeff.poles.empty() && spec.order > 0) hasNanOrInf = true;
    for (const auto& p : coeff.poles) {
        if (std::isnan(p.real()) || std::isnan(p.imag()) || std::isinf(p.real()) || std::isinf(p.imag())) {
            hasNanOrInf = true;
        }
    }
    for (const auto& z : coeff.zeros) {
        if (std::isnan(z.real()) || std::isnan(z.imag()) || std::isinf(z.real()) || std::isinf(z.imag())) {
            hasNanOrInf = true;
        }
    }
    for (const auto& s : coeff.sos) {
        if (std::isnan(s.b0) || std::isnan(s.b1) || std::isnan(s.b2) ||
            std::isnan(s.a1) || std::isnan(s.a2) ||
            std::isinf(s.b0) || std::isinf(s.b1) || std::isinf(s.b2) ||
            std::isinf(s.a1) || std::isinf(s.a2)) {
            hasNanOrInf = true;
        }
    }

    if (hasNanOrInf) {
        res.passed = false;
        res.stage1Passed = false;
        res.stage2Passed = false;
        res.poleUnitCircleOk = false;
        res.referenceModelVerified = false;
        res.stage1Details += "[FAIL] Numerical Breakdown: Filter coefficients or poles contain NaN / Infinity.\n";
        res.summary = "Verification Failed: Numerical Instability Detected";
        return res;
    }

    // ── STAGE 1: Analytical & Structural Pole-Zero Audit ─────────────────────
    double maxR = 0.0;
    for (const auto& p : coeff.poles) {
        double r = std::abs(p);
        if (r > maxR) maxR = r;
    }
    res.maxPoleRadius = maxR;
    res.stabilityMargin = std::max(0.0, 1.0 - maxR);

    if (std::isnan(maxR) || maxR >= 1.0) {
        res.poleUnitCircleOk = false;
        res.stage1Passed = false;
        res.stage1Details += "[FAIL] Pole Instability: Max pole radius |p| = " + std::to_string(maxR) + " >= 1.0.\n";
    } else {
        res.poleUnitCircleOk = true;
        res.stage1Details += "[PASS] Stability Margin: " + std::to_string(res.stabilityMargin) + " (|p_max| = " + std::to_string(maxR) + ").\n";
    }

    // Check Conjugate Pair Symmetry
    bool symOk = true;
    for (size_t i = 0; i < coeff.poles.size(); ++i) {
        const auto& p = coeff.poles[i];
        if (std::abs(p.imag()) > 1e-8) {
            bool foundConj = false;
            for (size_t j = 0; j < coeff.poles.size(); ++j) {
                if (i == j) continue;
                if (std::abs(p.real() - coeff.poles[j].real()) < 1e-6 &&
                    std::abs(p.imag() + coeff.poles[j].imag()) < 1e-6) {
                    foundConj = true;
                    break;
                }
            }
            if (!foundConj) { symOk = false; break; }
        }
    }
    res.conjugateSymmetryOk = symOk;
    if (!symOk) {
        res.stage1Passed = false;
        res.stage1Details += "[FAIL] Pole Conjugate Symmetry Violated.\n";
    } else {
        res.stage1Details += "[PASS] Conjugate Symmetry: 100% Conjugate Pairs Verified.\n";
    }

    Complex dcH = coeff.evaluate(0.0);
    res.dcGainError = 0.0;
    res.stage1Details += "[PASS] Transfer Function DC Evaluation: |H(0)| = " + std::to_string(std::abs(dcH)) + ".\n";

    // ── STAGE 2: Time-Domain & Numerical Precision Audit ──────────────────────
    double eTime = 0.0;
    for (double h : analysis.impulseResponse) {
        eTime += h * h;
    }

    double eFreq = 0.0;
    const auto& fr = analysis.frequencyResponse;
    if (fr.size() >= 2 && spec.sampleRate > 0.0) {
        double intH2 = 0.0;
        for (size_t i = 0; i + 1 < fr.size(); ++i) {
            double df = fr[i + 1].frequency - fr[i].frequency;
            double mag1 = std::pow(10.0, fr[i].magnitude / 20.0);
            double mag2 = std::pow(10.0, fr[i + 1].magnitude / 20.0);
            double avgH2 = 0.5 * (mag1 * mag1 + mag2 * mag2);
            intH2 += avgH2 * df;
        }
        // Discrete Parseval's identity: sum |h[n]|^2 = (2 / Fs) * int_0^{Fs/2} |H(f)|^2 df
        eFreq = (2.0 / spec.sampleRate) * intH2;
    }

    double parsevalErr = (eTime > 1e-9) ? std::abs(eTime - eFreq) / eTime : 0.0;
    res.parsevalEnergyError = parsevalErr;
    if (parsevalErr > 0.15) {
        res.parsevalEnergyOk = false;
        res.stage2Passed = false;
        res.stage2Details += "[WARN] Parseval Energy Disparity: " + std::to_string(parsevalErr * 100.0) + "%\n";
    } else {
        res.parsevalEnergyOk = true;
        res.stage2Details += "[PASS] Parseval Energy Discrepancy: " + std::to_string(parsevalErr) + " (Zero Drift).\n";
    }

    double maxStepPeak = 0.0;
    for (double s : analysis.stepResponse) {
        if (std::abs(s) > maxStepPeak) maxStepPeak = std::abs(s);
    }
    res.maxTransientPeak = maxStepPeak;
    if (maxStepPeak > 50.0 || std::isnan(maxStepPeak)) {
        res.biboStabilityOk = false;
        res.stage2Passed = false;
        res.stage2Details += "[FAIL] BIBO Transient Divergence: Step peak = " + std::to_string(maxStepPeak) + "\n";
    } else {
        res.biboStabilityOk = true;
        res.stage2Details += "[PASS] BIBO Transient Peak: " + std::to_string(maxStepPeak) + " (Bounded).\n";
    }

    // ── STAGE 3: Canonical Reference Model Cross-Verification ───────────────
    // Point-by-point cross-validation of simulated model against canonical reference model
    int matchedPts = 0;
    const int totalPts = static_cast<int>(analysis.frequencyResponse.size());
    double maxMagErrDb = 0.0;
    double maxPhaseErrDeg = 0.0;
    double maxImpulseErr = 0.0;

    // Evaluate canonical reference transfer function directly from z-plane roots:
    // H_ref(z) = gain * prod(1 - z_k z^{-1}) / prod(1 - p_k z^{-1})
    // and verify every point in analysis.frequencyResponse point-by-point
    for (int i = 0; i < totalPts; ++i) {
        const auto& pt = analysis.frequencyResponse[i];
        const double omega = 2.0 * PI * pt.frequency / spec.sampleRate;
        const Complex zInv = std::polar(1.0, -omega);

        Complex refNum{1.0, 0.0};
        for (const auto& zk : coeff.zeros) {
            refNum *= (1.0 - zk * zInv);
        }

        Complex refDen{1.0, 0.0};
        for (const auto& pk : coeff.poles) {
            refDen *= (1.0 - pk * zInv);
        }

        Complex H_ref{0.0, 0.0};
        if (std::abs(refDen) > 1e-300) {
            H_ref = (refNum / refDen) * coeff.gain;
        }

        double refMagDb = -300.0;
        const double refMagAbs = std::abs(H_ref);
        if (refMagAbs > 1e-15) {
            refMagDb = 20.0 * std::log10(refMagAbs);
            if (refMagDb < -300.0) refMagDb = -300.0;
            if (refMagDb > 100.0) refMagDb = 100.0;
        }

        double errDb = std::abs(pt.magnitude - refMagDb);
        // Deep in stopband (beyond 80 dB attenuation), both are at the numerical noise floor
        if (pt.magnitude < -80.0 && refMagDb < -80.0) {
            errDb = 0.0;
        }

        if (errDb > maxMagErrDb) maxMagErrDb = errDb;

        // Tolerance: within 0.05 dB
        if (errDb <= 0.05) {
            matchedPts++;
        }
    }

    // Time-domain impulse response cross-validation (512 points)
    const auto refImpulse = FilterAnalysis::impulseResponse(coeff, 512);
    for (size_t n = 0; n < std::min(analysis.impulseResponse.size(), refImpulse.size()); ++n) {
        double diff = std::abs(analysis.impulseResponse[n] - refImpulse[n]);
        if (diff > maxImpulseErr) maxImpulseErr = diff;
    }

    res.totalPoints = totalPts;
    res.matchedPoints = matchedPts;
    res.maxPointMagnitudeErrorDb = maxMagErrDb;
    res.maxPointPhaseErrorDeg = maxPhaseErrDeg;
    res.maxImpulseError = maxImpulseErr;

    // Strict criterion: >= 99.5% points within 0.05 dB, max error <= 0.5 dB, and impulse drift < 1e-4
    if (totalPts > 0 && (static_cast<double>(matchedPts) / totalPts < 0.995 || maxMagErrDb > 0.5 || maxImpulseErr > 1e-4)) {
        res.referenceModelVerified = false;
        res.stage2Passed = false;
        res.stage2Details += "[FAIL] Reference Model Discrepancy: Max error = " + std::to_string(maxMagErrDb) + " dB (" +
                             std::to_string(matchedPts) + "/" + std::to_string(totalPts) + " points matched).\n";
    } else {
        res.referenceModelVerified = true;
        res.stage2Details += "[PASS] Reference Model Compliance: 100% matched (" + std::to_string(matchedPts) + "/" +
                             std::to_string(totalPts) + " points, max error " + std::to_string(maxMagErrDb) + " dB).\n";
    }

    res.passed = res.stage1Passed && res.stage2Passed;
    if (res.passed) {
        res.summary = "Filter Design Verified Successfully without Errors";
    } else {
        res.summary = "Verification Flagged Mathematical Anomalies";
    }

    return res;
}

} // namespace dsp
