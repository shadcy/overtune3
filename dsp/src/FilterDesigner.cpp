#include "dsp/FilterCoefficients.h"
#include "Butterworth.h"
#include "Chebyshev.h"
#include "Elliptic.h"
#include "Bessel.h"
#include "dsp/FilterSpec.h"

// Factory function: dispatch to the correct designer based on FilterSpec
namespace dsp {

FilterCoefficients designFilter(const FilterSpec& spec) {
    switch (spec.response) {
        case FilterResponse::Butterworth:  return internal::designButterworth(spec);
        case FilterResponse::ChebyshevI:   return internal::designChebyshevI(spec);
        case FilterResponse::ChebyshevII:  return internal::designChebyshevII(spec);
        case FilterResponse::Elliptic:     return internal::designElliptic(spec);
        case FilterResponse::Bessel:       return internal::designBessel(spec);
    }
    return {};
}

} // namespace dsp
