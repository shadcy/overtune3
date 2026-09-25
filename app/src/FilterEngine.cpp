#include "FilterEngine.h"
#include "dsp/FilterDesigner.h"
#include "dsp/CodeExporter.h"
#include <QVariantMap>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QGuiApplication>
#include <QClipboard>
#include <stdexcept>

static QString presetsFilePath() {
    QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    return dir + "/presets.json";
}

static QJsonArray defaultPresets() {
    QJsonArray arr;
    auto makePreset = [](const QString& name, int type, int resp, int order, double fc, double fc2, double rp, double rs, double fs, const QString& desc) {
        QJsonObject o;
        o["name"] = name;
        o["type"] = type;
        o["response"] = resp;
        o["order"] = order;
        o["cutoffFreq"] = fc;
        o["cutoffFreq2"] = fc2;
        o["rippleDb"] = rp;
        o["stopbandDb"] = rs;
        o["sampleRate"] = fs;
        o["desc"] = desc;
        o["isUser"] = false;
        return o;
    };

    arr.append(makePreset("butterworth_lpf_1khz", 0, 0, 4, 1000, 0, 1.0, 40.0, 48000, "~/presets/audio/lowpass-48k"));
    arr.append(makePreset("chebyshev1_speech_bpf", 2, 1, 4, 300, 3400, 0.5, 40.0, 48000, "~/presets/telecom/bandpass-speech"));
    arr.append(makePreset("elliptic_mains_notch_50hz", 3, 3, 4, 48, 52, 1.0, 50.0, 48000, "~/presets/mains-hum/notch-50hz"));
    arr.append(makePreset("bessel_linear_phase_8k", 0, 4, 6, 8000, 0, 1.0, 40.0, 48000, "~/presets/mastering/linear-phase"));
    arr.append(makePreset("subsonic_rumble_hpf_80hz", 1, 0, 4, 80, 0, 1.0, 40.0, 48000, "~/presets/subsonic/rumble-cut"));
    arr.append(makePreset("chebyshev2_stopband_10k", 0, 2, 4, 10000, 0, 1.0, 60.0, 48000, "~/presets/scientific/monotonic-passband"));
    return arr;
}

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

QVariantList FilterEngine::loadPresets() {
    QFile f(presetsFilePath());
    QJsonArray arr;
    if (!f.exists()) {
        arr = defaultPresets();
        if (f.open(QIODevice::WriteOnly)) {
            f.write(QJsonDocument(arr).toJson());
            f.close();
        }
    } else {
        if (f.open(QIODevice::ReadOnly)) {
            QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
            if (doc.isArray()) arr = doc.array();
            f.close();
        }
    }

    QVariantList list;
    for (const auto& val : arr) {
        list.append(val.toObject().toVariantMap());
    }
    return list;
}

void FilterEngine::copyText(const QString& text) {
    if (auto* cb = QGuiApplication::clipboard()) {
        cb->setText(text);
    }
}

void FilterEngine::reset() {
    m_spec = dsp::FilterSpec{};
    emit specChanged();
    design();
}

bool FilterEngine::savePreset(const QString& name) {
    if (name.trimmed().isEmpty()) return false;
    QFile f(presetsFilePath());
    QJsonArray arr;
    if (f.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
        if (doc.isArray()) arr = doc.array();
        f.close();
    } else {
        arr = defaultPresets();
    }

    QJsonObject p;
    p["name"] = name.trimmed();
    p["type"] = static_cast<int>(m_spec.type);
    p["response"] = static_cast<int>(m_spec.response);
    p["order"] = m_spec.order;
    p["cutoffFreq"] = m_spec.cutoffFreq;
    p["cutoffFreq2"] = m_spec.cutoffFreq2;
    p["rippleDb"] = m_spec.rippleDb;
    p["stopbandDb"] = m_spec.stopbandDb;
    p["sampleRate"] = m_spec.sampleRate;
    p["desc"] = QString("User Preset · %1 %2 · Fc %3 Hz")
                    .arg(filterTypeName())
                    .arg(filterResponseName())
                    .arg(static_cast<int>(m_spec.cutoffFreq));
    p["isUser"] = true;

    bool replaced = false;
    for (int i = 0; i < arr.size(); ++i) {
        if (arr[i].toObject()["name"].toString() == name.trimmed()) {
            arr[i] = p;
            replaced = true;
            break;
        }
    }
    if (!replaced) arr.append(p);

    if (f.open(QIODevice::WriteOnly)) {
        f.write(QJsonDocument(arr).toJson());
        f.close();
        return true;
    }
    return false;
}

bool FilterEngine::deletePreset(const QString& name) {
    QFile f(presetsFilePath());
    QJsonArray arr;
    if (f.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
        if (doc.isArray()) arr = doc.array();
        f.close();
    } else {
        return false;
    }

    QJsonArray newArr;
    for (const auto& val : arr) {
        if (val.toObject()["name"].toString() != name) {
            newArr.append(val);
        }
    }

    if (f.open(QIODevice::WriteOnly)) {
        f.write(QJsonDocument(newArr).toJson());
        f.close();
        return true;
    }
    return false;
}

bool FilterEngine::applyPreset(const QString& name) {
    QFile f(presetsFilePath());
    QJsonArray arr;
    if (f.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
        if (doc.isArray()) arr = doc.array();
        f.close();
    } else {
        arr = defaultPresets();
    }

    for (const auto& val : arr) {
        QJsonObject o = val.toObject();
        if (o["name"].toString() == name) {
            m_spec.type = static_cast<dsp::FilterType>(o["type"].toInt());
            m_spec.response = static_cast<dsp::FilterResponse>(o["response"].toInt());
            m_spec.order = o["order"].toInt();
            m_spec.cutoffFreq = o["cutoffFreq"].toDouble();
            m_spec.cutoffFreq2 = o["cutoffFreq2"].toDouble();
            m_spec.rippleDb = o["rippleDb"].toDouble();
            m_spec.stopbandDb = o["stopbandDb"].toDouble();
            m_spec.sampleRate = o["sampleRate"].toDouble();
            emit specChanged();
            design();
            return true;
        }
    }
    return false;
}
