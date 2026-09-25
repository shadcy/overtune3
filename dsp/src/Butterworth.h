#pragma once
// Internal header — not part of the public API
#include "dsp/FilterCoefficients.h"
#include "dsp/FilterSpec.h"

namespace dsp::internal {

// Returns the Butterworth analog prototype poles for a given order.
FilterCoefficients designButterworth(const FilterSpec& spec);

} // namespace dsp::internal
