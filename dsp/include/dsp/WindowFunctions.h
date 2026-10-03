#pragma once

#include <string>
#include <vector>

namespace dsp {

enum class WindowNormalization {
    None,
    Peak,
    CoherentGain,
    Energy
};

struct WindowSpec {
    std::string name{"Hann"};
    int length{256};
    bool periodic{false};
    double kaiserBeta{8.6};
    double tukeyAlpha{0.5};
    double gaussianSigma{0.4};
    WindowNormalization normalization{WindowNormalization::None};
};

struct WindowResult {
    std::vector<double> coefficients;
    double sum{0.0};
    double energy{0.0};
    double coherentGain{0.0};
    double rms{0.0};
    double equivalentNoiseBandwidthBins{0.0};
};

class WindowFunctions {
public:
    static const std::vector<std::string>& names();
    static WindowResult generate(const WindowSpec& spec);
};

} // namespace dsp
