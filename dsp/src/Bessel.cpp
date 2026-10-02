#include "Bessel.h"
#include "BilinearTransform.h"
#include <cmath>
#include <vector>
#include <numbers>
#include <stdexcept>

// Bessel filter: maximally flat group delay.
// Poles computed from the reverse Bessel polynomials.

namespace dsp::internal {

// Reverse Bessel polynomial coefficients y_n(s) where n is the filter order.
// We compute them recursively: y_n = (2n-1)*y_{n-1} + s^2 * y_{n-2}
// Poles are the roots of y_n(s) = 0.

// Pre-computed Bessel pole tables for orders 1..10 (normalised to unit group delay)
// Source: Abramowitz & Stegun and Zverev's Handbook of Filter Synthesis
static const std::vector<std::vector<Complex>> BESSEL_POLES = {
    // n=1
    {{ -1.0, 0.0 }},
    // n=2
    {{ -1.5, 0.8660254038 }, { -1.5, -0.8660254038 }},
    // n=3
    {{ -2.3221853546, 0.0 }, { -1.8389069037, 1.7540575040 }, { -1.8389069037, -1.7540575040 }},
    // n=4
    {{ -2.8962131955, 0.8672341574 }, { -2.8962131955, -0.8672341574 },
     { -2.1042174590, 2.6574180387 }, { -2.1042174590, -2.6574180387 }},
    // n=5
    {{ -3.6467385953, 0.0 },
     { -3.3519563992, 1.7426614162 }, { -3.3519563992, -1.7426614162 },
     { -2.3246743032, 3.5710507407 }, { -2.3246743032, -3.5710507407 }},
    // n=6
    {{ -4.2483593959, 0.8675097584 }, { -4.2483593959, -0.8675097584 },
     { -3.7357083524, 2.6262723066 }, { -3.7357083524, -2.6262723066 },
     { -2.5159312068, 4.4926729337 }, { -2.5159312068, -4.4926729337 }},
    // n=7
    {{ -4.9717868585, 0.0 },
     { -4.7582905282, 1.7392479108 }, { -4.7582905282, -1.7392479108 },
     { -4.0701325935, 3.5171772682 }, { -4.0701325935, -3.5171772682 },
     { -2.6856768548, 5.4206941307 }, { -2.6856768548, -5.4206941307 }},
    // n=8
    {{ -5.5878854361, 0.8676559842 }, { -5.5878854361, -0.8676559842 },
     { -5.2048407671, 2.6161876590 }, { -5.2048407671, -2.6161876590 },
     { -4.3638398791, 4.4145488029 }, { -4.3638398791, -4.4145488029 },
     { -2.8397424329, 6.3539113157 }, { -2.8397424329, -6.3539113157 }},
    // n=9
    {{ -6.2970290419, 0.0 },
     { -6.0749546783, 1.7384948774 }, { -6.0749546783, -1.7384948774 },
     { -5.5574003590, 3.5143820513 }, { -5.5574003590, -3.5143820513 },
     { -4.6244311682, 5.3159720409 }, { -4.6244311682, -5.3159720409 },
     { -2.9792090765, 7.2901610605 }, { -2.9792090765, -7.2901610605 }},
    // n=10
    {{ -6.8063986282, 0.8676726752 }, { -6.8063986282, -0.8676726752 },
     { -6.5271851219, 2.6126986875 }, { -6.5271851219, -2.6126986875 },
     { -5.8922372048, 4.4110767189 }, { -5.8922372048, -4.4110767189 },
     { -4.8545323765, 6.2160169736 }, { -4.8545323765, -6.2160169736 },
     { -3.1072073713, 8.2296867948 }, { -3.1072073713, -8.2296867948 }}
};

FilterCoefficients designBessel(const FilterSpec& spec) {
    const int n = spec.order;
    if (n < 1 || n > 10)
        throw std::out_of_range("Bessel filter: order must be 1..10");

    const ComplexVec& prototypePoles = BESSEL_POLES[n - 1];

    // The tabulated poles have unit group-delay normalization. Find the
    // prototype's -3 dB frequency so the UI cutoff retains its usual meaning.
    auto prototypeMagnitude = [&](double omega) {
        Complex denominator{1.0, 0.0};
        double dcDenominator = 1.0;
        for (const auto& pole : prototypePoles) {
            denominator *= Complex{0.0, omega} - pole;
            dcDenominator *= std::abs(pole);
        }
        return dcDenominator / std::abs(denominator);
    };
    double lo = 0.0;
    double hi = 1.0;
    while (prototypeMagnitude(hi) > std::sqrt(0.5) && hi < 1e6)
        hi *= 2.0;
    for (int i = 0; i < 80; ++i) {
        const double mid = (lo + hi) * 0.5;
        if (prototypeMagnitude(mid) > std::sqrt(0.5)) lo = mid;
        else hi = mid;
    }
    const double cutoffScale = 1.0 / ((lo + hi) * 0.5);
    ComplexVec normalizedPoles;
    normalizedPoles.reserve(prototypePoles.size());
    for (const auto& pole : prototypePoles)
        normalizedPoles.push_back(pole * cutoffScale);

    return bilinearTransform(normalizedPoles, {}, 1.0, spec);
}

} // namespace dsp::internal
