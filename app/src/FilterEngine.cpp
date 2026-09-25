#include "FilterEngine.h"
#include "dsp/FilterDesigner.h"
#include "dsp/CodeExporter.h"
#include <QVariantMap>
#include <QDebug>
#include <stdexcept>

FilterEngine::FilterEngine(QObject* parent) : QObject(parent) {
    // Design with defaults on construction
    design();
}

void FilterEngine::setFilterType(int v) {
    auto t = static_cast<dsp::FilterType>(v);
    if (m_spec.type != t) {
        qDebug() << "[FilterEngine] setFilterType:" << v;
        m_spec.type = t; emit specChanged(); design();
    }
}
void FilterEngine::setFilterResponse(int v) {
    auto r = static_cast<dsp::FilterResponse>(v);
    if (m_spec.response != r) {
        qDebug() << "[FilterEngine] setFilterResponse:" << v;
        m_spec.response = r; emit specChanged(); design();
    }
}
void FilterEngine::setOrder(int v) {
    if (m_spec.order != v) {
        qDebug() << "[FilterEngine] setOrder:" << v;
        m_spec.order = v; emit specChanged(); design();
    }
}
void FilterEngine::setSampleRate(double v) {
    if (m_spec.sampleRate != v) {
        qDebug() << "[FilterEngine] setSampleRate:" << v;
        m_spec.sampleRate = v; emit specChanged(); design();
    }
}
void FilterEngine::setCutoffFreq(double v) {
    if (m_spec.cutoffFreq != v) {
        qDebug() << "[FilterEngine] setCutoffFreq:" << v;
        m_spec.cutoffFreq = v; emit specChanged(); design();
    }
}
void FilterEngine::setCutoffFreq2(double v) {
    if (m_spec.cutoffFreq2 != v) {
        qDebug() << "[FilterEngine] setCutoffFreq2:" << v;
        m_spec.cutoffFreq2 = v; emit specChanged(); design();
    }
}
void FilterEngine::setRippleDb(double v) {
    if (m_spec.rippleDb != v) {
        qDebug() << "[FilterEngine] setRippleDb:" << v;
        m_spec.rippleDb = v; emit specChanged(); design();
    }
}
void FilterEngine::setStopbandDb(double v) {
    if (m_spec.stopbandDb != v) {
        qDebug() << "[FilterEngine] setStopbandDb:" << v;
        m_spec.stopbandDb = v; emit specChanged(); design();
    }
}

void FilterEngine::design() {
    qDebug() << "[FilterEngine] design() running...";
    try {
        m_coeff      = dsp::designFilter(m_spec);
        auto result  = dsp::FilterAnalysis::compute(m_coeff, m_spec.sampleRate, 1024);
        m_hasResults = true;
        publishResults(result);
        qDebug() << "[FilterEngine] design() succeeded, freq points:" << m_magnitudeData.size();
    } catch (const std::exception& e) {
        m_hasResults = false;
        qWarning() << "[FilterEngine] design() failed:" << e.what();
        emit errorOccurred(QString::fromStdString(e.what()));
    }
}

void FilterEngine::publishResults(const dsp::AnalysisResult& r) {
    m_magnitudeData.clear();
    m_phaseData.clear();
    m_groupDelayData.clear();
    m_impulseData.clear();
    m_stepData.clear();
    m_poleZeroData.clear();

    for (const auto& p : r.frequencyResponse) {
        QVariantMap mag, ph, gd;
        mag["x"] = p.frequency; mag["y"] = p.magnitude;
        ph["x"]  = p.frequency; ph["y"]  = p.phase;
        gd["x"]  = p.frequency; gd["y"]  = p.groupDelay;
        m_magnitudeData.append(mag);
        m_phaseData.append(ph);
        m_groupDelayData.append(gd);
    }

    for (size_t i = 0; i < r.impulseResponse.size(); ++i) {
        QVariantMap pt;
        pt["x"] = static_cast<double>(i);
        pt["y"] = r.impulseResponse[i];
        m_impulseData.append(pt);
    }
    for (size_t i = 0; i < r.stepResponse.size(); ++i) {
        QVariantMap pt;
        pt["x"] = static_cast<double>(i);
        pt["y"] = r.stepResponse[i];
        m_stepData.append(pt);
    }

    // Poles = red, Zeros = blue
    for (const auto& p : r.poles) {
        QVariantMap pt;
        pt["re"]   = p.real(); pt["im"] = p.imag(); pt["kind"] = "pole";
        m_poleZeroData.append(pt);
    }
    for (const auto& z : r.zeros) {
        QVariantMap pt;
        pt["re"]   = z.real(); pt["im"] = z.imag(); pt["kind"] = "zero";
        m_poleZeroData.append(pt);
    }

    emit resultsChanged();
}

QString FilterEngine::exportCode(int format) {
    if (!m_hasResults) return {};
    try {
        auto fmt = static_cast<dsp::ExportFormat>(format);
        return QString::fromStdString(dsp::CodeExporter::generate(m_coeff, m_spec, fmt));
    } catch (const std::exception& e) {
        return QString("// Error: %1").arg(e.what());
    }
}

QString FilterEngine::filterTypeName()     const { return QString::fromStdString(m_spec.typeName()); }
QString FilterEngine::filterResponseName() const { return QString::fromStdString(m_spec.responseName()); }
