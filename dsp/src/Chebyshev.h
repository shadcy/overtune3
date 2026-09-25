#pragma once
// Internal header — not part of the public API
#include "dsp/FilterCoefficients.h"
#include "dsp/FilterSpec.h"

namespace dsp::internal {

// Chebyshev Type I and Type II filters
FilterCoefficients designChebyshevI (const FilterSpec& spec);
FilterCoefficients designChebyshevII(const FilterSpec& spec);

} // namespace dsp::internal
