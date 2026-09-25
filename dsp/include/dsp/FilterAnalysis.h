#pragma once
#include "dsp/FilterCoefficients.h"
#include <vector>

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

class FilterAnalysis {
public:
    // numPoints: number of frequency points (log-spaced, 1 Hz → Fs/2)
    static AnalysisResult compute(const FilterCoefficients& coeff,
                                  double sampleRate,
                                  int    numPoints = 1024);

    static std::vector<double> impulseResponse(const FilterCoefficients& coeff, int length = 256);
    static std::vector<double> stepResponse   (const FilterCoefficients& coeff, int length = 256);
};

} // namespace dsp
