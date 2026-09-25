#include "SimulationModel.h"
#include "FilterEngine.h"
#include "dsp/WavReader.h"
#include "dsp/CsvReader.h"
#include "dsp/SignalProcessor.h"
#include <cmath>
#include <numbers>
#include <QVariantMap>

SimulationModel::SimulationModel(QObject* parent) : QObject(parent) {}

void SimulationModel::loadWav(const QString& path) {
    try {
        auto samples = dsp::WavReader::readMono(path.toStdString());
        m_label = QStringLiteral("WAV: ") + path.section('/', -1);
        publish(samples);
    } catch (const std::exception& e) {
        emit errorOccurred(QString::fromStdString(e.what()));
    }
}

void SimulationModel::loadCsv(const QString& path, int column) {
    try {
        auto samples = dsp::CsvReader::readColumn(path.toStdString(), column);
        m_label = QStringLiteral("CSV: ") + path.section('/', -1);
        publish(samples);
    } catch (const std::exception& e) {
        emit errorOccurred(QString::fromStdString(e.what()));
    }
}

void SimulationModel::generateSine(double freq, double sampleRate, double durationSec) {
    const int n = static_cast<int>(sampleRate * durationSec);
    std::vector<double> samples(n);
    const double omega = 2.0 * std::numbers::pi * freq / sampleRate;
    for (int i = 0; i < n; ++i) samples[i] = std::sin(omega * i);
    m_label = QString("Sine %1 Hz").arg(freq);
    publish(samples);
}

void SimulationModel::generateChirp(double f0, double f1, double sampleRate, double durationSec) {
    const int n = static_cast<int>(sampleRate * durationSec);
    std::vector<double> samples(n);
    const double pi = std::numbers::pi;
    const double k  = (f1 - f0) / durationSec;
    for (int i = 0; i < n; ++i) {
        const double t = i / sampleRate;
        samples[i] = std::sin(2.0 * pi * (f0 * t + 0.5 * k * t * t));
    }
    m_label = QString("Chirp %1–%2 Hz").arg(f0).arg(f1);
    publish(samples);
}

void SimulationModel::applyFilter(QObject* enginePtr) {
    if (m_rawInput.empty()) return;
    auto* eng = qobject_cast<FilterEngine*>(enginePtr);
    if (!eng) return;

    // Force a design to get valid coefficients
    eng->design();

    // We need access to the internal coefficients — expose via a signal path
    // For now, re-design and grab from engine by requesting it to store them
    // (this is a simplified approach; in production you'd pass coeff directly)
    emit dataChanged();
}

void SimulationModel::clear() {
    m_input.clear();
    m_output.clear();
    m_rawInput.clear();
    m_label.clear();
    emit dataChanged();
}

void SimulationModel::publish(const std::vector<double>& input) {
    m_rawInput = input;
    m_input.clear();
    m_output.clear();

    // Downsample to max 4096 points for display
    const int dispMax = 4096;
    const int step = std::max(1, static_cast<int>(input.size()) / dispMax);
    for (int i = 0; i < static_cast<int>(input.size()); i += step) {
        QVariantMap pt;
        pt["x"] = static_cast<double>(i);
        pt["y"] = input[i];
        m_input.append(pt);
    }

    emit dataChanged();
}
