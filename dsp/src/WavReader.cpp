#include "dsp/WavReader.h"
#include <cstdint>
#include <cstring>
#include <fstream>
#include <stdexcept>
#include <vector>

namespace dsp {

namespace {

struct WavHeader {
    char     riff[4];
    uint32_t chunkSize;
    char     wave[4];
};

struct FmtChunk {
    uint16_t audioFormat;    // 1=PCM, 3=float
    uint16_t numChannels;
    uint32_t sampleRate;
    uint32_t byteRate;
    uint16_t blockAlign;
    uint16_t bitsPerSample;
};

} // anonymous namespace

WavData WavReader::read(const std::string& path) {
    WavData data;
    std::ifstream f(path, std::ios::binary);
    if (!f) { data.error = "Cannot open file: " + path; return data; }

    WavHeader hdr{};
    f.read(reinterpret_cast<char*>(&hdr), 12);
    if (std::memcmp(hdr.riff, "RIFF", 4) || std::memcmp(hdr.wave, "WAVE", 4)) {
        data.error = "Not a valid WAV file"; return data;
    }

    FmtChunk fmt{};
    std::vector<uint8_t> pcmData;

    char     chunkId[4];
    uint32_t chunkSize = 0;
    while (f.read(chunkId, 4) && f.read(reinterpret_cast<char*>(&chunkSize), 4)) {
        if (std::memcmp(chunkId, "fmt ", 4) == 0) {
            const uint32_t readBytes = std::min<uint32_t>(chunkSize, sizeof(FmtChunk));
            f.read(reinterpret_cast<char*>(&fmt), readBytes);
            if (chunkSize > sizeof(FmtChunk))
                f.seekg(chunkSize - sizeof(FmtChunk), std::ios::cur);
        } else if (std::memcmp(chunkId, "data", 4) == 0) {
            pcmData.resize(chunkSize);
            f.read(reinterpret_cast<char*>(pcmData.data()), chunkSize);
            break;
        } else {
            f.seekg(chunkSize, std::ios::cur);
        }
    }

    if (pcmData.empty()) { data.error = "No data chunk found"; return data; }

    data.channels      = fmt.numChannels;
    data.sampleRate    = static_cast<int>(fmt.sampleRate);
    data.bitsPerSample = fmt.bitsPerSample;
    data.valid         = true;

    const int    bytesPerSample = fmt.bitsPerSample / 8;
    const size_t numSamples     = pcmData.size() / static_cast<size_t>(bytesPerSample);
    data.samples.reserve(numSamples);

    for (size_t i = 0; i < numSamples; ++i) {
        const uint8_t* p = pcmData.data() + i * static_cast<size_t>(bytesPerSample);
        double sample = 0.0;
        if (fmt.audioFormat == 1) { // PCM integer
            switch (fmt.bitsPerSample) {
                case 8: {
                    sample = (static_cast<double>(*p) - 128.0) / 128.0;
                    break;
                }
                case 16: {
                    int16_t v = 0;
                    std::memcpy(&v, p, 2);
                    sample = v / 32768.0;
                    break;
                }
                case 24: {
                    int32_t v = (static_cast<int32_t>(p[2]) << 24 |
                                 static_cast<int32_t>(p[1]) << 16 |
                                 static_cast<int32_t>(p[0]) << 8) >> 8;
                    sample = v / 8388608.0;
                    break;
                }
                case 32: {
                    int32_t v = 0;
                    std::memcpy(&v, p, 4);
                    sample = v / 2147483648.0;
                    break;
                }
                default: break;
            }
        } else if (fmt.audioFormat == 3) { // IEEE 32-bit float
            float v = 0.0f;
            std::memcpy(&v, p, 4);
            sample = static_cast<double>(v);
        }
        data.samples.push_back(sample);
    }

    return data;
}

std::vector<double> WavReader::readMono(const std::string& path) {
    auto d = read(path);
    if (!d.valid || d.samples.empty()) return {};
    if (d.channels == 1) return d.samples;
    // Mix down to mono
    std::vector<double> mono;
    mono.reserve(d.samples.size() / static_cast<size_t>(d.channels));
    for (size_t i = 0; i < d.samples.size(); i += static_cast<size_t>(d.channels)) {
        double sum = 0.0;
        for (int c = 0; c < d.channels; ++c) sum += d.samples[i + static_cast<size_t>(c)];
        mono.push_back(sum / d.channels);
    }
    return mono;
}

} // namespace dsp
