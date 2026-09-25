#pragma once
#include "dsp/FilterCoefficients.h"
#include "dsp/FilterSpec.h"

namespace dsp {

// Factory: design a filter from a FilterSpec. Returns FilterCoefficients.
FilterCoefficients designFilter(const FilterSpec& spec);

} // namespace dsp
