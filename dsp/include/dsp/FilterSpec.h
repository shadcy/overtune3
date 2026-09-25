#pragma once
#include <cstdint>
#include <string>

namespace dsp {

enum class FilterType {
    LowPass,
    HighPass,
    BandPass,
    BandStop
};

enum class FilterResponse {
    Butterworth,
    ChebyshevI,
    ChebyshevII,
    Elliptic,
    Bessel
};

struct FilterSpec {
    FilterType     type     = FilterType::LowPass;
    FilterResponse response = FilterResponse::Butterworth;
    int            order    = 4;
    double         sampleRate = 48000.0;   // Hz
    double         cutoffFreq = 1000.0;    // Hz  (LPF / HPF)
    double         cutoffFreq2 = 2000.0;   // Hz  (BPF / BSF upper)
    double         rippleDb  = 1.0;        // Chebyshev / Elliptic passband ripple
    double         stopbandDb = 60.0;      // Elliptic stopband attenuation

    [[nodiscard]] std::string typeName()     const noexcept;
    [[nodiscard]] std::string responseName() const noexcept;
};

} // namespace dsp
