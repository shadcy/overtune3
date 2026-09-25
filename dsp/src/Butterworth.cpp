#include "Butterworth.h"
#include "BilinearTransform.h"
#include <cmath>
#include <numbers>

namespace dsp::internal {

FilterCoefficients designButterworth(const FilterSpec& spec) {
    const int n = spec.order;
    const double pi = std::numbers::pi;

    // Analog LPF prototype poles on the unit circle in the left-half s-plane
    ComplexVec poles;
    poles.reserve(n);
    for (int k = 1; k <= n; ++k) {
        const double theta = pi * (2.0 * k + n - 1.0) / (2.0 * n);
        poles.push_back(Complex{ std::cos(theta), std::sin(theta) });
    }

    // Butterworth prototype: no finite zeros
    ComplexVec zeros;   // empty → all zeros at infinity

    return bilinearTransform(poles, zeros, 1.0, spec);
}

} // namespace dsp::internal
