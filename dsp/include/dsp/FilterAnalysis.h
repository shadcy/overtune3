#pragma once
#include "dsp/FilterCoefficients.h"
#include "dsp/FilterSpec.h"
#include <vector>
#include <string>

namespace dsp {

struct AnalysisPoint {
    double frequency;   // Hz
    double magnitude;   // dB
    double phase;       // degrees
    double groupDelay;  // samples
};

struct AnalysisResult {
    std::vector<AnalysisPoint> frequencyResponse;  // magnitude + phase + group delay
    ComplexVec                 poles;
    ComplexVec                 zeros;
    double                     gain{1.0};
    std::vector<double>        impulseResponse;    // first 256 samples
    std::vector<double>        stepResponse;       // first 256 samples
};

struct VerificationResult {
    bool passed{true};
    bool stage1Passed{true};
    bool stage2Passed{true};

    // Stage 1 (Analytical & Structural Integrity)
    double maxPoleRadius{0.0};
    double stabilityMargin{1.0};
    bool conjugateSymmetryOk{true};
    bool poleUnitCircleOk{true};
    double dcGainError{0.0};
    std::string stage1Details;

    // Stage 2 (Time-Domain & Numerical Precision)
    double parsevalEnergyError{0.0};
    bool parsevalEnergyOk{true};
    double maxTransientPeak{0.0};
    bool biboStabilityOk{true};

    // Reference Model Cross-Verification (point-by-point audit against canonical reference model)
    bool referenceModelVerified{true};
    bool specificationOk{true};
    int matchedPoints{0};
    int totalPoints{0};
    double maxPointMagnitudeErrorDb{0.0};
    double maxPointPhaseErrorDeg{0.0};
    double maxGroupDelayRelativeError{0.0};
    double maxSpecificationErrorDb{0.0};
    double maxImpulseError{0.0};
    std::string stage2Details;

    std::string summary;
};

class FilterAnalysis {
public:
    // numPoints: base number of frequency points (log-spaced + critical edge clusters)
    static AnalysisResult compute(const FilterCoefficients& coeff,
                                  double sampleRate,
                                  int    numPoints = 2048,
                                  double cutoff1 = -1.0,
                                  double cutoff2 = -1.0);

    // Evaluate a single continuous frequency point analytically
    static AnalysisPoint evaluatePoint(const FilterCoefficients& coeff,
                                       double sampleRate,
                                       double freqHz);

    static std::vector<double> impulseResponse(const FilterCoefficients& coeff, int length = 512);
    static std::vector<double> stepResponse   (const FilterCoefficients& coeff, int length = 512);

    // 2-Stage Mathematical Verifier
    static VerificationResult verify(const FilterSpec& spec,
                                     const FilterCoefficients& coeff,
                                     const AnalysisResult& analysis);
};

} // namespace dsp
