#pragma once
// Internal header — not part of the public API
#include "dsp/FilterCoefficients.h"
#include "dsp/FilterSpec.h"

namespace dsp::internal {

// Maps an s-domain analog prototype to the desired digital frequency band
// using the bilinear transform with pre-warping.
// Returns SOS coefficients in the z domain.
FilterCoefficients bilinearTransform(const ComplexVec& analogPoles,
                                     const ComplexVec& analogZeros,
                                     double            analogGain,
                                     const FilterSpec& spec);

// Pre-warp a digital frequency (Hz) to an analog frequency (rad/s)
double prewarp(double freqHz, double sampleRate) noexcept;

} // namespace dsp::internal
