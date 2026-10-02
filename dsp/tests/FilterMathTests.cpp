#include "dsp/FilterAnalysis.h"
#include "dsp/FilterDesigner.h"

#include <cmath>
#include <iostream>
#include <numbers>
#include <stdexcept>

namespace {

int failures = 0;

void check(bool condition, const char* message) {
    if (!condition) {
        std::cerr << "FAIL: " << message << '\n';
        ++failures;
    }
}

void runDesignMatrix() {
    for (int response = 0; response < 5; ++response) {
        const int maxOrder = response == static_cast<int>(dsp::FilterResponse::Bessel) ? 10 : 16;
        for (int type = 0; type < 4; ++type) {
            for (int order : {1, 2, 3, 4, maxOrder}) {
                dsp::FilterSpec spec;
                spec.response = static_cast<dsp::FilterResponse>(response);
                spec.type = static_cast<dsp::FilterType>(type);
                spec.order = order;
                spec.sampleRate = 48000.0;
                spec.cutoffFreq = type >= 2 ? 900.0 : 1000.0;
                spec.cutoffFreq2 = type >= 2 ? 1100.0 : 2000.0;
                spec.rippleDb = 1.0;
                spec.stopbandDb = 60.0;

                const auto coeff = dsp::designFilter(spec);
                const int expectedOrder = order * (type >= 2 ? 2 : 1);
                check(static_cast<int>(coeff.poles.size()) == expectedOrder,
                      "pole count matches transformed filter order");
                check(coeff.zeros.size() == coeff.poles.size(),
                      "finite zero count matches pole count");
                check(coeff.sos.size() == static_cast<size_t>((expectedOrder + 1) / 2),
                      "SOS count matches filter order");
                for (const auto& pole : coeff.poles)
                    check(std::isfinite(pole.real()) && std::isfinite(pole.imag()) && std::abs(pole) < 1.0,
                          "all digital poles are finite and strictly stable");

                if (type <= 2) {
                    double expectedDb = -3.0102999566;
                    if (response == static_cast<int>(dsp::FilterResponse::ChebyshevI) ||
                        response == static_cast<int>(dsp::FilterResponse::Elliptic))
                        expectedDb = -spec.rippleDb;
                    else if (response == static_cast<int>(dsp::FilterResponse::ChebyshevII))
                        expectedDb = -spec.stopbandDb;
                    const int edgeCount = type == 2 ? 2 : 1;
                    for (int edge = 0; edge < edgeCount; ++edge) {
                        const double edgeHz = edge == 0 ? spec.cutoffFreq : spec.cutoffFreq2;
                        const double edgeDb = 20.0 * std::log10(std::abs(
                            coeff.evaluate(2.0 * std::numbers::pi * edgeHz / spec.sampleRate)));
                        check(std::isfinite(edgeDb) && std::abs(edgeDb - expectedDb) < 0.1,
                              "filter cutoff edges meet response-family specification");
                    }
                }

                const auto analysis = dsp::FilterAnalysis::compute(
                    coeff, spec.sampleRate, 1024, spec.cutoffFreq,
                    type >= 2 ? spec.cutoffFreq2 : -1.0);
                check(analysis.frequencyResponse.size() >= 1024,
                      "frequency grid is populated");
                for (const auto& point : analysis.frequencyResponse) {
                    check(std::isfinite(point.frequency) && std::isfinite(point.magnitude) &&
                          std::isfinite(point.phase) && std::isfinite(point.groupDelay),
                          "plot samples are finite");
                }
                const auto verified = dsp::FilterAnalysis::verify(spec, coeff, analysis);
                if (!verified.referenceModelVerified) {
                    std::cerr << "reference mismatch response=" << response << " type=" << type
                              << " order=" << order << " mag=" << verified.maxPointMagnitudeErrorDb
                              << " phase=" << verified.maxPointPhaseErrorDeg
                              << " gdRel=" << verified.maxGroupDelayRelativeError
                              << " impulse=" << verified.maxImpulseError
                              << " matched=" << verified.matchedPoints << "/" << verified.totalPoints
                              << " details=" << verified.stage2Details << '\n';
                    check(false, "independent SOS, phase, group-delay, and impulse checks pass");
                }
                check(verified.passed && verified.specificationOk,
                      "full verifier accepts designs meeting their family specifications");
            }
        }
    }
}

void runInvalidSpecChecks() {
    dsp::FilterSpec spec;
    spec.cutoffFreq = 24000.0;
    bool rejected = false;
    try { (void)dsp::designFilter(spec); }
    catch (const std::invalid_argument&) { rejected = true; }
    check(rejected, "Nyquist cutoff is rejected");

    spec = {};
    spec.type = dsp::FilterType::BandPass;
    spec.cutoffFreq = 1200.0;
    spec.cutoffFreq2 = 1000.0;
    rejected = false;
    try { (void)dsp::designFilter(spec); }
    catch (const std::invalid_argument&) { rejected = true; }
    check(rejected, "reversed band edges are rejected");
}

} // namespace

int main() {
    runDesignMatrix();
    runInvalidSpecChecks();
    if (failures != 0) {
        std::cerr << failures << " DSP math checks failed\n";
        return 1;
    }
    std::cout << "DSP math checks passed\n";
    return 0;
}
