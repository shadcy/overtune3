#pragma once
// Internal header — not part of the public API
#include "dsp/FilterCoefficients.h"
#include "dsp/FilterSpec.h"

namespace dsp::internal {

FilterCoefficients designBessel(const FilterSpec& spec);

} // namespace dsp::internal
