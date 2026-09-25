#include "Chebyshev.h"
#include "BilinearTransform.h"
#include <cmath>
#include <numbers>

namespace dsp::internal {

// ─── Chebyshev Type I ─────────────────────────────────────────────────────────
FilterCoefficients designChebyshevI(const FilterSpec& spec) {
    const int n = spec.order;
    const double eps = std::sqrt(std::pow(10.0, spec.rippleDb / 10.0) - 1.0);
    const double a   = std::asinh(1.0 / eps) / static_cast<double>(n);
    const double pi  = std::numbers::pi;

    ComplexVec poles;
    poles.reserve(n);
    for (int k = 1; k <= n; ++k) {
        const double theta = pi * (2.0 * k - 1.0) / (2.0 * n);
        poles.push_back(Complex{
            -std::sinh(a) * std::sin(theta),
             std::cosh(a) * std::cos(theta)
        });
    }

    return bilinearTransform(poles, {}, 1.0, spec);
}

// ─── Chebyshev Type II ────────────────────────────────────────────────────────
FilterCoefficients designChebyshevII(const FilterSpec& spec) {
    const int n = spec.order;
    const double eps = 1.0 / std::sqrt(std::pow(10.0, spec.stopbandDb / 10.0) - 1.0);
    const double a   = std::asinh(1.0 / eps) / static_cast<double>(n);
    const double pi  = std::numbers::pi;

    ComplexVec poles, zeros;
    poles.reserve(n);

    for (int k = 1; k <= n; ++k) {
        const double theta = pi * (2.0 * k - 1.0) / (2.0 * n);
        // Prototype poles are the reciprocal of Type I poles
        const Complex p0 = Complex{
            -std::sinh(a) * std::sin(theta),
             std::cosh(a) * std::cos(theta)
        };
        poles.push_back(1.0 / p0);
    }

    // Zeros of Type II are on the imaginary axis: ±j / cos(θ_k)
    for (int k = 1; k <= n / 2; ++k) {
        const double theta = pi * (2.0 * k - 1.0) / (2.0 * n);
        const double zImag = 1.0 / std::cos(theta);
        zeros.push_back(Complex{ 0.0,  zImag });
        zeros.push_back(Complex{ 0.0, -zImag });
    }

    return bilinearTransform(poles, zeros, 1.0, spec);
}

} // namespace dsp::internal
