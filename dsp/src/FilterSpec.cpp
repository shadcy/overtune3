#include "dsp/FilterSpec.h"

namespace dsp {

std::string FilterSpec::typeName() const noexcept {
    switch (type) {
        case FilterType::LowPass:  return "Low Pass";
        case FilterType::HighPass: return "High Pass";
        case FilterType::BandPass: return "Band Pass";
        case FilterType::BandStop: return "Band Stop";
    }
    return "Unknown";
}

std::string FilterSpec::responseName() const noexcept {
    switch (response) {
        case FilterResponse::Butterworth:  return "Butterworth";
        case FilterResponse::ChebyshevI:   return "Chebyshev I";
        case FilterResponse::ChebyshevII:  return "Chebyshev II";
        case FilterResponse::Elliptic:     return "Elliptic";
        case FilterResponse::Bessel:       return "Bessel";
    }
    return "Unknown";
}

} // namespace dsp
