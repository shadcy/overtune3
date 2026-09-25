#pragma once
#include <complex>
#include <vector>

namespace dsp {

using Complex   = std::complex<double>;
using ComplexVec = std::vector<Complex>;

// Transfer function H(z) = B(z) / A(z), stored as SOS (Second-Order Sections)
// Each section is [b0, b1, b2, a0, a1, a2].
struct Biquad {
    double b0{1}, b1{0}, b2{0};
    double a0{1}, a1{0}, a2{0};
};

struct FilterCoefficients {
    std::vector<Biquad> sos;           // Second-order sections (normalised, a0=1)
    double              gain{1.0};     // Overall gain
    ComplexVec          poles;         // z-domain poles
    ComplexVec          zeros;         // z-domain zeros

    [[nodiscard]] bool  isValid()  const noexcept { return !sos.empty(); }
    [[nodiscard]] int   order()    const noexcept { return static_cast<int>(sos.size()) * 2; }

    // Evaluate H(z) at a given normalised digital frequency ω ∈ [0, π]
    [[nodiscard]] Complex evaluate(double omega) const noexcept;
};

} // namespace dsp
