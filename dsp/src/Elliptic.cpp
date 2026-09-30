#include "Elliptic.h"
#include "BilinearTransform.h"
#include <cmath>
#include <numbers>
#include <vector>
#include <algorithm>

namespace dsp::internal {

static constexpr double PI = std::numbers::pi;

// Complete elliptic integral of the first kind K(k) via Arithmetic-Geometric Mean (AGM)
static double ellipticK(double k) {
    k = std::clamp(std::abs(k), 0.0, 1.0 - 1e-15);
    double a = 1.0;
    double b = std::sqrt(std::max(0.0, 1.0 - k * k));
    for (int i = 0; i < 24; ++i) {
        const double an = (a + b) / 2.0;
        const double bn = std::sqrt(a * b);
        a = an;
        b = bn;
        if (std::abs(a - b) < 1e-15) break;
    }
    return PI / (2.0 * a);
}

// Jacobi elliptic functions sn(u, k), cn(u, k), dn(u, k) via descending Landen / AGM
struct JacobiResult {
    double sn{0.0};
    double cn{1.0};
    double dn{1.0};
};

static JacobiResult jacobiEllipj(double u, double k) {
    k = std::clamp(std::abs(k), 0.0, 1.0 - 1e-15);
    if (k < 1e-12) {
        return { std::sin(u), std::cos(u), 1.0 };
    }

    std::vector<double> a, b, c;
    a.push_back(1.0);
    b.push_back(std::sqrt(std::max(0.0, 1.0 - k * k)));
    c.push_back(k);

    for (int i = 0; i < 24; ++i) {
        const double an = (a.back() + b.back()) / 2.0;
        const double bn = std::sqrt(a.back() * b.back());
        const double cn = (a.back() - b.back()) / 2.0;
        a.push_back(an);
        b.push_back(bn);
        c.push_back(cn);
        if (std::abs(cn) < 1e-15) break;
    }

    const size_t N = a.size() - 1;
    double phi = std::pow(2.0, static_cast<double>(N)) * a[N] * u;

    for (size_t i = N; i > 0; --i) {
        const double ratio = (c[i] / a[i]) * std::sin(phi);
        phi = 0.5 * (phi + std::asin(std::clamp(ratio, -1.0, 1.0)));
    }

    const double sn = std::sin(phi);
    const double cn = std::cos(phi);
    const double dn = std::sqrt(std::max(0.0, 1.0 - k * k * sn * sn));
    return { sn, cn, dn };
}

// Solve degree equation for elliptic modulus k:
// K(k) / K'(k) = n * (K(k1) / K'(k1))
static double solveEllipticK(int n, double k1) {
    const double K1 = ellipticK(k1);
    const double K1p = ellipticK(std::sqrt(std::max(0.0, 1.0 - k1 * k1)));
    const double targetRatio = static_cast<double>(n) * (K1 / K1p);

    double lo = 1e-12;
    double hi = 1.0 - 1e-12;
    for (int iter = 0; iter < 80; ++iter) {
        const double mid = (lo + hi) / 2.0;
        const double K = ellipticK(mid);
        const double Kp = ellipticK(std::sqrt(std::max(0.0, 1.0 - mid * mid)));
        const double ratio = K / Kp;
        if (ratio < targetRatio) {
            lo = mid;
        } else {
            hi = mid;
        }
    }
    return (lo + hi) / 2.0;
}

FilterCoefficients designElliptic(const FilterSpec& spec) {
    const int n = std::clamp(spec.order, 1, 16);
    const double Rp = std::max(0.01, spec.rippleDb);
    const double Rs = std::max(Rp + 1.0, spec.stopbandDb);

    const double eps_sq = std::pow(10.0, 0.1 * Rp) - 1.0;
    const double k1_sq = eps_sq / (std::pow(10.0, 0.1 * Rs) - 1.0);
    const double k1 = std::sqrt(std::clamp(k1_sq, 1e-12, 1.0 - 1e-12));
    const double k1p = std::sqrt(std::max(0.0, 1.0 - k1 * k1));

    const double k = solveEllipticK(n, k1);
    const double kp = std::sqrt(std::max(0.0, 1.0 - k * k));
    const double capK = ellipticK(k);
    const double K1 = ellipticK(k1);
    const double K1p = ellipticK(k1p);

    // Solve for r where sn(r, k1p) = 1.0 / sqrt(1 + eps^2)
    const double targetSn = 1.0 / std::sqrt(1.0 + eps_sq);
    double rLo = 0.0;
    double rHi = K1p;
    for (int iter = 0; iter < 60; ++iter) {
        const double mid = (rLo + rHi) / 2.0;
        const auto res = jacobiEllipj(mid, k1p);
        if (res.sn < targetSn) {
            rLo = mid;
        } else {
            rHi = mid;
        }
    }
    const double r = (rLo + rHi) / 2.0;
    const double v0 = capK * r / (static_cast<double>(n) * K1);
    const auto vRes = jacobiEllipj(v0, kp);
    const double sv = vRes.sn;
    const double cv = vRes.cn;
    const double dv = vRes.dn;

    ComplexVec poles;
    ComplexVec zeros;
    poles.reserve(n);
    zeros.reserve(n);

    const int jStart = 1 - (n % 2);
    for (int j = jStart; j < n; j += 2) {
        if (j == 0) {
            // Real pole for odd order: p0 = -sv / cv
            const double p0 = (std::abs(cv) > 1e-15) ? (-sv / cv) : -1.0;
            poles.push_back(Complex{ p0, 0.0 });
        } else {
            const double u = static_cast<double>(j) * capK / static_cast<double>(n);
            const auto uRes = jacobiEllipj(u, k);
            const double s = uRes.sn;
            const double c = uRes.cn;
            const double d = uRes.dn;

            // Finite transmission zeros on imaginary axis: ±j / (k * s)
            if (std::abs(k * s) > 1e-12) {
                const double zImag = 1.0 / (k * s);
                zeros.push_back(Complex{ 0.0,  zImag });
                zeros.push_back(Complex{ 0.0, -zImag });
            }

            // Complex-conjugate pole pair
            const double denom = 1.0 - (d * sv) * (d * sv);
            if (std::abs(denom) > 1e-15) {
                const double pReal = -(c * d * sv * cv) / denom;
                const double pImag = (s * dv) / denom;
                poles.push_back(Complex{ pReal,  pImag });
                poles.push_back(Complex{ pReal, -pImag });
            }
        }
    }

    // DC gain normalization: H(0) = 1.0 for odd order, or 10^(-Rp/20) for even order
    double numGain = 1.0;
    for (const auto& p : poles) numGain *= std::abs(p);
    double denGain = 1.0;
    for (const auto& z : zeros) denGain *= std::abs(z);
    double analogGain = (denGain > 1e-12) ? (numGain / denGain) : numGain;
    if (n % 2 == 0) {
        analogGain /= std::sqrt(1.0 + eps_sq);
    }

    return bilinearTransform(poles, zeros, analogGain, spec);
}

} // namespace dsp::internal
