#include "dsp/SignalProcessor.h"

namespace dsp {

std::vector<double> SignalProcessor::process(const FilterCoefficients& coeff,
                                              const std::vector<double>& input) {
    SignalProcessor sp;
    sp.setCoefficients(coeff);
    std::vector<double> out;
    out.reserve(input.size());
    for (double s : input)
        out.push_back(sp.processSample(s));
    return out;
}

void SignalProcessor::reset() {
    for (auto& s : m_state) s = {};
}

void SignalProcessor::setCoefficients(const FilterCoefficients& coeff) {
    m_coeff = coeff;
    m_state.assign(coeff.sos.size(), {});
}

double SignalProcessor::processSample(double x) {
    // Direct Form II Transposed biquad cascade
    double y = x * m_coeff.gain;
    for (size_t i = 0; i < m_coeff.sos.size(); ++i) {
        const auto& s = m_coeff.sos[i];
        const double w   = y - s.a1 * m_state[i].x1 - s.a2 * m_state[i].x2;
        const double out = s.b0 * w + s.b1 * m_state[i].x1 + s.b2 * m_state[i].x2;
        m_state[i].x2 = m_state[i].x1;
        m_state[i].x1 = w;
        y = out;
    }
    return y;
}

} // namespace dsp
