#pragma once
#include <string>
#include <vector>

namespace dsp {

struct WavData {
    int                  channels{};
    int                  sampleRate{};
    int                  bitsPerSample{};
    std::vector<double>  samples;  // always interleaved as doubles in [-1,1]
    bool                 valid{false};
    std::string          error;
};

class WavReader {
public:
    static WavData read(const std::string& path);
    // Returns mono mix-down; if stereo, averages channels
    static std::vector<double> readMono(const std::string& path);
};

} // namespace dsp
