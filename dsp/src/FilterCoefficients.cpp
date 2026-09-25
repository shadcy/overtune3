#include "dsp/FilterCoefficients.h"
#include <cmath>

namespace dsp {

Complex FilterCoefficients::evaluate(double omega) const noexcept {
    // z = e^{jω}
    const Complex z = std::polar(1.0, omega);
    Complex H{gain};
    for (const auto& s : sos) {
        const Complex num = s.b0 + s.b1 / z + s.b2 / (z * z);
        const Complex den = 1.0 + s.a1 / z + s.a2 / (z * z);
        if (std::abs(den) < 1e-300) continue;
        H *= num / den;
    }
    return H;
}

} // namespace dsp
