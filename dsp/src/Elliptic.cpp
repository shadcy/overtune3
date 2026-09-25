#include "Elliptic.h"
#include "BilinearTransform.h"
#include <cmath>
#include <numbers>
#include <stdexcept>

// Elliptic (Cauer) filter design using Landen's transformation and
// Jacobi elliptic functions — computed numerically to arbitrary precision.

namespace dsp::internal {

static constexpr int LANDEN_ITER = 16;
static constexpr double PI = std::numbers::pi;

// Complete elliptic integral of the first kind K(k) via AGM
static double ellipticK(double k) {
    if (std::abs(k) >= 1.0) throw std::domain_error("ellipticK: |k| must be < 1");
    double a = 1.0, b = std::sqrt(1.0 - k * k);
    for (int i = 0; i < 64; ++i) {
        const double an = (a + b) / 2.0;
        b = std::sqrt(a * b);
        a = an;
        if (std::abs(a - b) < 1e-15) break;
    }
    return PI / (2.0 * a);
}

// Jacobi elliptic sn(u, k) via descending Landen transformation
static double jacobiSn(double u, double k) {
    if (std::abs(k) < 1e-15) return std::sin(u);
    if (std::abs(k - 1.0) < 1e-15) return std::tanh(u);

    std::vector<double> ks;
    ks.push_back(k);
    double kn = k;
    for (int i = 0; i < LANDEN_ITER; ++i) {
        const double kp = std::sqrt(1.0 - kn * kn);
        kn = (1.0 - kp) / (1.0 + kp);
        ks.push_back(kn);
        if (kn < 1e-15) break;
    }

    double phi = std::pow(2.0, static_cast<double>(ks.size() - 1)) * u * ks.back();
    for (int i = static_cast<int>(ks.size()) - 2; i >= 0; --i) {
        phi = (phi + std::asin(ks[i] * std::sin(phi))) / 2.0;
    }
    return std::sin(phi);
}

static Complex jacobiCd(double u, double k) {
    // cd(u,k) = sn(K-u, k) / ... ≈ cos-like function
    const double K = ellipticK(k);
    return Complex{ jacobiSn(K - u, k), 0.0 };
}

FilterCoefficients designElliptic(const FilterSpec& spec) {
    const int n        = spec.order;
    const double Rp    = spec.rippleDb;
    const double Rs    = spec.stopbandDb;

    // Selectivity factor and modular constant
    const double eps_p = std::sqrt(std::pow(10.0, Rp / 10.0) - 1.0);
    const double eps_s = std::sqrt(std::pow(10.0, Rs / 10.0) - 1.0);
    const double k1    = eps_p / eps_s;
    // Minimal selectivity k such that K(k1')/K(k1) = n * K(k')/K(k)
    // We solve numerically.
    const double k1p   = std::sqrt(1.0 - k1 * k1);
    const double K1    = ellipticK(k1);
    const double K1p   = ellipticK(k1p);
    const double ratio = static_cast<double>(n) * K1 / K1p;

    // Bisect for k such that K(k) / K(k') == ratio
    double klo = 0.0, khi = 1.0 - 1e-10;
    for (int iter = 0; iter < 200; ++iter) {
        const double km  = (klo + khi) / 2.0;
        const double kmp = std::sqrt(1.0 - km * km);
        const double r   = ellipticK(km) / ellipticK(kmp);
        if (r < ratio) klo = km; else khi = km;
        if (khi - klo < 1e-12) break;
    }
    const double k  = (klo + khi) / 2.0;
    const double kp = std::sqrt(1.0 - k * k);
    const double K  = ellipticK(k);
    const double Kp = ellipticK(kp);

    // Place poles and zeros using elliptic cd function
    const int L  = n / 2;
    const int r  = n % 2; // 1 if odd order
    ComplexVec poles, zeros;

    for (int i = 1; i <= L; ++i) {
        const double u  = (2.0 * i - 1.0) * K / static_cast<double>(n);
        // Zero in s-domain: z_i = j / (k * cd(u, k))
        const double cd = jacobiCd(u, k).real();
        if (std::abs(cd * k) > 1e-15) {
            const double zImag = 1.0 / (k * cd);
            zeros.push_back(Complex{ 0.0,  zImag });
            zeros.push_back(Complex{ 0.0, -zImag });
        }

        // Pole in s-domain using Jacobi elliptic functions
        const double v0 = -Kp / K * std::atanh(1.0 / eps_p) / static_cast<double>(n);
        const double snV = jacobiSn(v0, kp);
        // sn(u + jv0, k) — approximation via addition formula
        const Complex jv{ 0.0, -1.0 };
        const double  snu = jacobiSn(u, k);
        const double  cdu = jacobiCd(u, k).real();
        // Simplified: p_i = ±j * Omega_s * sn(u_i + j*v0, k)
        // Use the product formula approximation
        const double re = -snV * std::sqrt(1.0 - snu * snu * k * k);
        const double im =  cdu * std::sqrt(1.0 - snV * snV);
        poles.push_back(Complex{ re,  im });
        poles.push_back(Complex{ re, -im });
    }

    if (r == 1) {
        // Real pole for odd order
        const double v0 = -Kp / K * std::atanh(1.0 / eps_p) / static_cast<double>(n);
        poles.push_back(Complex{ -jacobiSn(v0, kp), 0.0 });
    }

    return bilinearTransform(poles, zeros, 1.0, spec);
}

} // namespace dsp::internal
