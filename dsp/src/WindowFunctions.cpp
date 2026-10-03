#include "dsp/WindowFunctions.h"

#include <algorithm>
#include <cmath>
#include <limits>
#include <numbers>
#include <stdexcept>

namespace dsp {
namespace {

constexpr double pi = std::numbers::pi_v<double>;

double besselI0(double x) {
    const double quarterSquare = x * x * 0.25;
    double term = 1.0;
    double sum = 1.0;
    for (int k = 1; k < 128; ++k) {
        term *= quarterSquare / (static_cast<double>(k) * k);
        sum += term;
        if (term <= sum * std::numeric_limits<double>::epsilon()) break;
    }
    return sum;
}

double sinc(double x) {
    if (std::abs(x) < 1e-12) return 1.0;
    const double px = pi * x;
    return std::sin(px) / px;
}

double cosineSeries(double phase, const double* a, int count) {
    double value = a[0];
    for (int k = 1; k < count; ++k)
        value += (k % 2 ? -1.0 : 1.0) * a[k] * std::cos(k * phase);
    return value;
}

} // namespace

const std::vector<std::string>& WindowFunctions::names() {
    static const std::vector<std::string> values{
        "Rectangular", "Bartlett", "Hann", "Hamming", "Blackman",
        "Blackman-Harris", "Nuttall", "Flat Top", "Kaiser", "Tukey",
        "Gaussian", "Bohman", "Lanczos"
    };
    return values;
}

WindowResult WindowFunctions::generate(const WindowSpec& spec) {
    if (spec.length < 3 || spec.length > 65536)
        throw std::invalid_argument("Window length must be between 3 and 65536 samples.");
    if (!std::isfinite(spec.kaiserBeta) || spec.kaiserBeta < 0.0 || spec.kaiserBeta > 20.0)
        throw std::invalid_argument("Kaiser beta must be finite and between 0 and 20.");
    if (!std::isfinite(spec.tukeyAlpha) || spec.tukeyAlpha < 0.0 || spec.tukeyAlpha > 1.0)
        throw std::invalid_argument("Tukey alpha must be finite and between 0 and 1.");
    if (!std::isfinite(spec.gaussianSigma) || spec.gaussianSigma < 0.01 || spec.gaussianSigma > 10.0)
        throw std::invalid_argument("Gaussian sigma must be finite and between 0.01 and 10.");
    const int normalization = static_cast<int>(spec.normalization);
    if (normalization < 0 || normalization > 3)
        throw std::invalid_argument("Unknown window normalization mode.");
    if (std::find(names().begin(), names().end(), spec.name) == names().end())
        throw std::invalid_argument("Unknown window function.");

    const int n = spec.length;
    const int denominator = spec.periodic ? n : n - 1;
    const double center = denominator / 2.0;
    const double i0Beta = besselI0(spec.kaiserBeta);
    constexpr double blackman[] = {0.42, 0.5, 0.08};
    constexpr double blackmanHarris[] = {0.35875, 0.48829, 0.14128, 0.01168};
    constexpr double nuttall[] = {0.355768, 0.487396, 0.144232, 0.012604};
    constexpr double flatTop[] = {0.21557895, 0.41663158, 0.277263158,
                                  0.083578947, 0.006947368};

    WindowResult result;
    result.coefficients.resize(static_cast<size_t>(n));
    for (int i = 0; i < n; ++i) {
        const double phase = 2.0 * pi * static_cast<double>(i) / denominator;
        const double x = center == 0.0 ? 0.0 : (static_cast<double>(i) - center) / center;
        const double ax = std::abs(x);
        double w = 0.0;

        if (spec.name == "Rectangular") w = 1.0;
        else if (spec.name == "Bartlett") w = 1.0 - ax;
        else if (spec.name == "Hann") w = 0.5 * (1.0 - std::cos(phase));
        else if (spec.name == "Hamming") w = 0.54 - 0.46 * std::cos(phase);
        else if (spec.name == "Blackman") w = cosineSeries(phase, blackman, 3);
        else if (spec.name == "Blackman-Harris") w = cosineSeries(phase, blackmanHarris, 4);
        else if (spec.name == "Nuttall") w = cosineSeries(phase, nuttall, 4);
        else if (spec.name == "Flat Top") w = cosineSeries(phase, flatTop, 5);
        else if (spec.name == "Kaiser")
            w = besselI0(spec.kaiserBeta * std::sqrt(std::max(0.0, 1.0 - x * x))) / i0Beta;
        else if (spec.name == "Tukey") {
            const double alpha = spec.tukeyAlpha;
            if (alpha <= 0.0) w = 1.0;
            else if (alpha >= 1.0) w = 0.5 * (1.0 + std::cos(pi * x));
            else if (ax >= 1.0) w = 0.0;
            else if (ax > 1.0 - alpha)
                w = 0.5 * (1.0 + std::cos(pi * (ax - 1.0 + alpha) / alpha));
            else w = 1.0;
        } else if (spec.name == "Gaussian") {
            const double scaled = x / spec.gaussianSigma;
            w = std::exp(-0.5 * scaled * scaled);
        } else if (spec.name == "Bohman") {
            w = (1.0 - ax) * std::cos(pi * ax) + std::sin(pi * ax) / pi;
        } else if (spec.name == "Lanczos") w = sinc(x);

        result.coefficients[static_cast<size_t>(i)] = w;
    }

    auto& values = result.coefficients;
    const double peak = *std::max_element(values.begin(), values.end());
    double sum = 0.0;
    double energy = 0.0;
    for (double w : values) {
        sum += w;
        energy += w * w;
    }
    switch (spec.normalization) {
        case WindowNormalization::None: break;
        case WindowNormalization::Peak:
            if (!(peak > 0.0)) throw std::runtime_error("Window peak cannot be normalized.");
            for (double& w : values) w /= peak;
            break;
        case WindowNormalization::CoherentGain:
            if (std::abs(sum) < 1e-14) throw std::runtime_error("Window coherent gain is too small to normalize.");
            for (double& w : values) w *= n / sum;
            break;
        case WindowNormalization::Energy:
            if (!(energy > 1e-28)) throw std::runtime_error("Window energy is too small to normalize.");
            for (double& w : values) w *= std::sqrt(n / energy);
            break;
    }

    result.sum = 0.0;
    result.energy = 0.0;
    for (double w : values) {
        result.sum += w;
        result.energy += w * w;
    }
    result.coherentGain = result.sum / n;
    result.rms = std::sqrt(result.energy / n);
    result.equivalentNoiseBandwidthBins = std::abs(result.sum) > 1e-14
        ? n * result.energy / (result.sum * result.sum)
        : 0.0;
    return result;
}

} // namespace dsp
