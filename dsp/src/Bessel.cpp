#include "Bessel.h"
#include "BilinearTransform.h"
#include <cmath>
#include <vector>
#include <numbers>
#include <stdexcept>

// Bessel filter: maximally flat group delay.
// Poles are the roots of the reverse Bessel polynomials (tabulated below).

namespace dsp::internal {

// Poles of the analog Bessel prototype, normalised to unit group delay at DC:
// the roots of the reverse Bessel polynomial
//   theta_n(s) = sum_k (2n - k)! / (2^(n-k) k! (n-k)!) s^k.
// Computed to 40 digits (mpmath) and rounded to double precision; they agree
// with scipy.signal.besselap(norm='delay'). Regenerate rather than hand-edit.
static const std::vector<std::vector<Complex>> BESSEL_POLES = {
    // n=1
    {{ -1.0, 0.0 }},
    // n=2
    {{ -1.5, 0.86602540378443865 }, { -1.5, -0.86602540378443865 }},
    // n=3
    {{ -2.3221853546260856, 0.0 },
     { -1.8389073226869572, 1.7543809597837217 }, { -1.8389073226869572, -1.7543809597837217 }},
    // n=4
    {{ -2.8962106028203722, 0.86723412893450375 }, { -2.8962106028203722, -0.86723412893450375 },
     { -2.1037893971796278, 2.6574180418567527 }, { -2.1037893971796278, -2.6574180418567527 }},
    // n=5
    {{ -3.6467385953296433, 0.0 },
     { -3.3519563991535331, 1.7426614161831977 }, { -3.3519563991535331, -1.7426614161831977 },
     { -2.3246743031816452, 3.5710229203379764 }, { -2.3246743031816452, -3.5710229203379764 }},
    // n=6
    {{ -4.2483593958633639, 0.86750967323136561 }, { -4.2483593958633639, -0.86750967323136561 },
     { -3.7357083563258147, 2.6262723114471256 }, { -3.7357083563258147, -2.6262723114471256 },
     { -2.5159322478108214, 4.4926729536539425 }, { -2.5159322478108214, -4.4926729536539425 }},
    // n=7
    {{ -4.9717868585279357, 0.0 },
     { -4.7582905281546289, 1.7392860611305365 }, { -4.7582905281546289, -1.7392860611305365 },
     { -4.0701391636381375, 3.5171740477097532 }, { -4.0701391636381375, -3.5171740477097532 },
     { -2.6856768789432657, 5.4206941307167489 }, { -2.6856768789432657, -5.4206941307167489 }},
    // n=8
    {{ -5.5878860432630852, 0.86761444535278646 }, { -5.5878860432630852, -0.86761444535278646 },
     { -5.2048407906368819, 2.6161751526425274 }, { -5.2048407906368819, -2.6161751526425274 },
     { -4.3682892172024024, 4.4144425004715391 }, { -4.3682892172024024, -4.4144425004715391 },
     { -2.8389839488976305, 6.3539112986048768 }, { -2.8389839488976305, -6.3539112986048768 }},
    // n=9
    {{ -6.2970191817149685, 0.0 },
     { -6.1293679042742728, 1.7378483834808625 }, { -6.1293679042742728, -1.7378483834808625 },
     { -5.6044218195077814, 3.4981569178860936 }, { -5.6044218195077814, -3.4981569178860936 },
     { -4.6384398871803903, 5.3172716754356511 }, { -4.6384398871803903, -5.3172716754356511 },
     { -2.9792607981800712, 7.2914636883421821 }, { -2.9792607981800712, -7.2914636883421821 }},
    // n=10
    {{ -6.9220449054272461, 0.86766519545122144 }, { -6.9220449054272461, -0.86766519545122144 },
     { -6.6152909654768703, 2.6115679208000899 }, { -6.6152909654768703, -2.6115679208000899 },
     { -5.9675283285877858, 4.3849471889419321 }, { -5.9675283285877858, -4.3849471889419321 },
     { -4.8862195668589996, 6.2249854824715671 }, { -4.8862195668589996, -6.2249854824715671 },
     { -3.1089162336490982, 8.2326994590735875 }, { -3.1089162336490982, -8.2326994590735875 }}
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
