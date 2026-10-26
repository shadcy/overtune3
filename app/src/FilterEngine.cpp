#include "FilterEngine.h"
#include "dsp/CodeExporter.h"
#include "dsp/FilterDesigner.h"
#include <QClipboard>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QImage>
#include <QByteArray>
#include <QRegularExpression>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <QVariantMap>
#include <algorithm>
#include <cmath>
#include <cstring>
#include <memory>
#include <stdexcept>
#include <QUrl>
#include <QDateTime>

static QString presetsFilePath() {
  QString dir =
      QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
  QDir().mkpath(dir);
  return dir + "/presets.json";
}

static QJsonArray defaultPresets() {
  QJsonArray arr;
  auto makePreset = [](const QString &name, int type, int resp, int order,
                       double fc, double fc2, double rp, double rs, double fs,
                       const QString &desc) {
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

  arr.append(makePreset("butterworth_lpf_1khz", 0, 0, 4, 1000, 0, 1.0, 40.0,
                        48000, "~/presets/audio/lowpass-48k"));
  arr.append(makePreset("chebyshev1_speech_bpf", 2, 1, 4, 300, 3400, 0.5, 40.0,
                        48000, "~/presets/telecom/bandpass-speech"));
  arr.append(makePreset("elliptic_mains_notch_50hz", 3, 3, 4, 48, 52, 1.0, 50.0,
                        48000, "~/presets/mains-hum/notch-50hz"));
  arr.append(makePreset("bessel_linear_phase_8k", 0, 4, 6, 8000, 0, 1.0, 40.0,
                        48000, "~/presets/mastering/linear-phase"));
  arr.append(makePreset("subsonic_rumble_hpf_80hz", 1, 0, 4, 80, 0, 1.0, 40.0,
                        48000, "~/presets/subsonic/rumble-cut"));
  arr.append(makePreset("chebyshev2_stopband_10k", 0, 2, 4, 10000, 0, 1.0, 60.0,
                        48000, "~/presets/scientific/monotonic-passband"));
  arr.append(makePreset("fir_linear_phase_lpf_4k", 0, 5, 64, 4000, 0, 1.0, 60.0,
                        48000, "~/presets/fir/linear-phase-lowpass"));
  return arr;
}

FilterEngine::FilterEngine(QObject *parent) : QObject(parent) {
  // Every spec edit invalidates results computed from an older spec
  connect(this, &FilterEngine::specChanged, this, [this]() { ++m_specGen; });

  // Throttle rather than debounce: while scrubbing, the curve keeps following
  // (about one redesign per frame) instead of freezing until the pointer stops
  m_throttleTimer.setSingleShot(true);
  m_throttleTimer.setInterval(16);
  connect(&m_throttleTimer, &QTimer::timeout, this, &FilterEngine::startAsyncDesign);

  // One worker: runs never overlap, and only the newest pending spec is run
  m_pool.setMaxThreadCount(1);

  // Initial design calculation on startup
  designInternal();
}

FilterEngine::~FilterEngine() {
  // A running job posts its result back to this object; let it finish first
  m_pool.waitForDone();
}

void FilterEngine::scheduleDesign() {
  if (!m_throttleTimer.isActive())
    m_throttleTimer.start();
}

FilterEngine::DesignOutcome FilterEngine::runDesign(const dsp::FilterSpec &spec, int points,
                                                    double cutoff2, quint64 gen) {
  DesignOutcome out;
  out.gen = gen;
  try {
    out.coeff = dsp::designFilter(spec);
    out.analysis = dsp::FilterAnalysis::compute(out.coeff, spec.sampleRate, points,
                                                spec.cutoffFreq, cutoff2);
  } catch (const std::exception &e) {
    out.error = QString::fromStdString(e.what());
  }
  return out;
}

void FilterEngine::startAsyncDesign() {
  if (m_jobRunning) {
    m_jobPending = true;   // picked up when the running job finishes
    return;
  }
  if (m_specGen <= m_publishedGen) return;   // already showing this spec
  m_jobRunning = true;
  m_jobPending = false;
  const dsp::FilterSpec spec = m_spec;
  const int points = m_analysisPoints;
  const double cutoff2 = analysisCutoff2();
  const quint64 gen = m_specGen;
  m_pool.start([this, spec, points, cutoff2, gen]() {
    auto outcome = std::make_shared<DesignOutcome>(runDesign(spec, points, cutoff2, gen));
    QMetaObject::invokeMethod(this, [this, outcome]() {
      finishAsyncDesign(std::move(*outcome));
    }, Qt::QueuedConnection);
  });
}

void FilterEngine::finishAsyncDesign(DesignOutcome &&outcome) {
  m_jobRunning = false;
  // Intermediate results are shown while a drag continues, but a run never
  // replaces a newer one (e.g. a synchronous design() made meanwhile)
  if (outcome.gen > m_publishedGen)
    applyOutcome(std::move(outcome));
  if (m_jobPending) {
    m_jobPending = false;
    startAsyncDesign();
  }
}

// Enum ranges accepted from QML and preset files
static constexpr int kLastType = static_cast<int>(dsp::FilterType::BandStop);
static constexpr int kLastResponse = static_cast<int>(dsp::FilterResponse::FIR);
static constexpr int kLastWindow = static_cast<int>(dsp::FirWindow::DolphChebyshev);

void FilterEngine::setFilterType(int v) {
  if (v < 0 || v > kLastType) return;
  auto t = static_cast<dsp::FilterType>(v);
  if (m_spec.type != t) {
    qDebug() << "[FilterEngine] setFilterType:" << v;
    m_spec.type = t;
    emit specChanged();
    design(); // Discrete type change runs immediately
  }
}
// Highest order the DSP library accepts for a given response family
static int maxOrderFor(dsp::FilterResponse r) {
  switch (r) {
    case dsp::FilterResponse::Bessel: return 10;
    case dsp::FilterResponse::FIR:    return 256;
    default:                          return 16;
  }
}

// IIR and FIR orders live on different scales (4 vs 64), so each class keeps
// its own last-used order across IIR <-> FIR switches.
void FilterEngine::rememberOrder() {
  (m_spec.isFir() ? m_firOrder : m_iirOrder) = m_spec.order;
}

int FilterEngine::orderFor(int response) const {
  if (response < 0 || response > kLastResponse) return m_spec.order;
  const auto r = static_cast<dsp::FilterResponse>(response);
  const bool fir = r == dsp::FilterResponse::FIR;
  const int order = fir == m_spec.isFir() ? m_spec.order : (fir ? m_firOrder : m_iirOrder);
  return std::clamp(order, 1, maxOrderFor(r));
}

int FilterEngine::maxOrder(int response) const {
  if (response < 0 || response > kLastResponse) return maxOrderFor(m_spec.response);
  return maxOrderFor(static_cast<dsp::FilterResponse>(response));
}

void FilterEngine::setFilterResponse(int v) {
  if (v < 0 || v > kLastResponse) return;
  auto r = static_cast<dsp::FilterResponse>(v);
  if (m_spec.response != r) {
    qDebug() << "[FilterEngine] setFilterResponse:" << v;
    const int order = orderFor(v);
    rememberOrder();
    m_spec.response = r;
    m_spec.order = order;
    emit specChanged();
    design(); // Discrete response change runs immediately
  }
}

void FilterEngine::applySpec(const QVariantMap &m) {
  rememberOrder();
  dsp::FilterSpec s = m_spec;
  auto readInt = [&](const char *key, int last, int current) {
    if (!m.contains(key)) return current;
    const int v = m.value(key).toInt();
    return (v >= 0 && v <= last) ? v : current;
  };
  auto readDouble = [&](const char *key, double current) {
    bool ok = false;
    const double v = m.value(key).toDouble(&ok);
    return (m.contains(key) && ok && std::isfinite(v)) ? v : current;
  };
  s.type = static_cast<dsp::FilterType>(readInt("filterType", kLastType, static_cast<int>(s.type)));
  s.response = static_cast<dsp::FilterResponse>(
      readInt("filterResponse", kLastResponse, static_cast<int>(s.response)));
  s.firWindow = static_cast<dsp::FirWindow>(readInt("firWindow", kLastWindow, static_cast<int>(s.firWindow)));
  s.order = std::clamp(m.contains("order") ? m.value("order").toInt() : s.order, 1, maxOrderFor(s.response));
  s.sampleRate = readDouble("sampleRate", s.sampleRate);
  s.cutoffFreq = readDouble("cutoffFreq", s.cutoffFreq);
  s.cutoffFreq2 = readDouble("cutoffFreq2", s.cutoffFreq2);
  s.rippleDb = readDouble("rippleDb", s.rippleDb);
  s.stopbandDb = readDouble("stopbandDb", s.stopbandDb);
  s.firWindowParam = readDouble("firWindowParam", s.firWindowParam);
  m_spec = s;
  rememberOrder();
  emit specChanged();
  design(); // one design for the whole change set, no intermediate states
}
void FilterEngine::setOrder(int v) {
  v = std::clamp(v, 1, maxOrderFor(m_spec.response));
  if (m_spec.order != v) {
    qDebug() << "[FilterEngine] setOrder:" << v;
    m_spec.order = v;
    rememberOrder();
    emit specChanged();
    design(); // Order change runs immediately
  }
}
void FilterEngine::setSampleRate(double v) {
  if (m_spec.sampleRate != v) {
    qDebug() << "[FilterEngine] setSampleRate:" << v;
    m_spec.sampleRate = v;
    // Keep the band edges below the new Nyquist frequency so lowering the
    // sample rate does not leave an undesignable spec behind
    const double nyquist = v / 2.0;
    if (m_spec.cutoffFreq2 >= nyquist) m_spec.cutoffFreq2 = std::floor(nyquist * 0.95);
    if (m_spec.cutoffFreq >= nyquist) m_spec.cutoffFreq = std::floor(nyquist * 0.45);
    if (m_spec.cutoffFreq2 <= m_spec.cutoffFreq)
      m_spec.cutoffFreq2 = std::min(std::floor(nyquist * 0.95), m_spec.cutoffFreq * 2.0);
    emit specChanged();
    scheduleDesign();
  }
}
void FilterEngine::setCutoffFreq(double v) {
  if (m_spec.cutoffFreq != v) {
    m_spec.cutoffFreq = v;
    emit specChanged();
    scheduleDesign();
  }
}
void FilterEngine::setCutoffFreq2(double v) {
  if (m_spec.cutoffFreq2 != v) {
    m_spec.cutoffFreq2 = v;
    emit specChanged();
    scheduleDesign();
  }
}
void FilterEngine::setRippleDb(double v) {
  if (m_spec.rippleDb != v) {
    m_spec.rippleDb = v;
    emit specChanged();
    scheduleDesign();
  }
}
void FilterEngine::setStopbandDb(double v) {
  if (m_spec.stopbandDb != v) {
    m_spec.stopbandDb = v;
    emit specChanged();
    scheduleDesign();
  }
}

void FilterEngine::setFirWindow(int v) {
  if (v < 0 || v > kLastWindow) return;
  auto w = static_cast<dsp::FirWindow>(v);
  if (m_spec.firWindow != w) {
    m_spec.firWindow = w;
    emit specChanged();
    design(); // Discrete window change runs immediately
  }
}

void FilterEngine::setFirWindowParam(double v) {
  if (m_spec.firWindowParam != v) {
    m_spec.firWindowParam = v;
    emit specChanged();
    scheduleDesign();
  }
}

int FilterEngine::effectiveOrder() const {
  // High-pass and band-stop FIR designs need an even order (odd tap count)
  const bool needsEven = m_spec.type == dsp::FilterType::HighPass ||
                         m_spec.type == dsp::FilterType::BandStop;
  if (m_spec.isFir() && needsEven && m_spec.order % 2 != 0)
    return m_spec.order + 1;
  return m_spec.order;
}

double FilterEngine::edgeDb() const {
  // Same edge targets the design verifier checks against
  switch (m_spec.response) {
    case dsp::FilterResponse::ChebyshevI:
    case dsp::FilterResponse::Elliptic:    return -m_spec.rippleDb;
    case dsp::FilterResponse::ChebyshevII: return -m_spec.stopbandDb;
    case dsp::FilterResponse::FIR:         return -6.0206;
    default:                               return -3.0103;
  }
}

QString FilterEngine::orderLabel() const {
  const int n = effectiveOrder();
  const int lastTwo = n % 100;
  const char *suffix = "th";
  if (lastTwo < 11 || lastTwo > 13) {
    switch (n % 10) {
      case 1: suffix = "st"; break;
      case 2: suffix = "nd"; break;
      case 3: suffix = "rd"; break;
      default: break;
    }
  }
  return QString("%1%2 order").arg(n).arg(suffix);
}

QStringList FilterEngine::firWindowNames() const {
  QStringList names;
  dsp::FilterSpec probe;
  for (int i = 0; i <= static_cast<int>(dsp::FirWindow::DolphChebyshev); ++i) {
    probe.firWindow = static_cast<dsp::FirWindow>(i);
    names << QString::fromStdString(probe.windowName());
  }
  return names;
}

QString FilterEngine::toLocalPath(const QString &urlOrPath) const {
  if (urlOrPath.startsWith("file:", Qt::CaseInsensitive))
    return QUrl(urlOrPath).toLocalFile();
  return urlOrPath;
}

void FilterEngine::setAnalysisPoints(int points) {
  points = std::clamp(points, 512, 16384);
  if (points != m_analysisPoints) {
    m_analysisPoints = points;
    ++m_specGen;   // same spec, but the shown grid is now out of date
    scheduleDesign();
  }
}

void FilterEngine::design() {
  designInternal();
}

// The second cutoff only exists for band designs; low/high-pass specs keep a
// stale value that may sit below the first cutoff, so it must not reach the
// analysis grid (which rejects unordered edges).
double FilterEngine::analysisCutoff2() const {
  const bool band = m_spec.type == dsp::FilterType::BandPass ||
                    m_spec.type == dsp::FilterType::BandStop;
  return band ? m_spec.cutoffFreq2 : -1.0;
}

QVariantMap FilterEngine::verifyDesign() {
  QVariantMap map;
  if (!m_hasResults) {
    map["passed"] = false;
    map["summary"] = QString("No valid design to verify");
    return map;
  }
  dsp::VerificationResult ver;
  try {
    auto analysis = dsp::FilterAnalysis::compute(
        m_coeff, m_spec.sampleRate, 2048, m_spec.cutoffFreq, analysisCutoff2());
    ver = dsp::FilterAnalysis::verify(m_spec, m_coeff, analysis);
  } catch (const std::exception &e) {
    map["passed"] = false;
    map["summary"] = QString::fromStdString(e.what());
    return map;
  }

  map["passed"] = ver.passed;
  map["stage1Passed"] = ver.stage1Passed;
  map["stage2Passed"] = ver.stage2Passed;
  map["maxPoleRadius"] = ver.maxPoleRadius;
  map["stabilityMargin"] = ver.stabilityMargin;
  map["conjugateSymmetryOk"] = ver.conjugateSymmetryOk;
  map["poleUnitCircleOk"] = ver.poleUnitCircleOk;
  map["stage1Details"] = QString::fromStdString(ver.stage1Details);
  map["parsevalEnergyError"] = ver.parsevalEnergyError;
  map["parsevalEnergyOk"] = ver.parsevalEnergyOk;
  map["maxTransientPeak"] = ver.maxTransientPeak;
  map["biboStabilityOk"] = ver.biboStabilityOk;
  map["referenceModelVerified"] = ver.referenceModelVerified;
  map["specificationOk"] = ver.specificationOk;
  map["matchedPoints"] = ver.matchedPoints;
  map["totalPoints"] = ver.totalPoints;
  map["maxPointMagnitudeErrorDb"] = ver.maxPointMagnitudeErrorDb;
  map["maxPointPhaseErrorDeg"] = ver.maxPointPhaseErrorDeg;
  map["maxGroupDelayRelativeError"] = ver.maxGroupDelayRelativeError;
  map["maxSpecificationErrorDb"] = ver.maxSpecificationErrorDb;
  map["maxImpulseError"] = ver.maxImpulseError;
  map["stage2Details"] = QString::fromStdString(ver.stage2Details);
  map["summary"] = QString::fromStdString(ver.summary);
  return map;
}

void FilterEngine::designInternal() {
  // A synchronous run supersedes any queued live update
  m_throttleTimer.stop();
  m_jobPending = false;
  applyOutcome(runDesign(m_spec, m_analysisPoints, analysisCutoff2(), m_specGen));
}

void FilterEngine::applyOutcome(DesignOutcome &&outcome) {
  m_publishedGen = outcome.gen;
  if (!outcome.error.isEmpty()) {
    m_hasResults = false;
    qWarning() << "[FilterEngine] design failed:" << outcome.error;
    emit resultsChanged();
    // Live scrubbing through an invalid spec would otherwise repeat the same
    // message every frame
    if (outcome.error != m_lastError)
      emit errorOccurred(outcome.error);
    m_lastError = outcome.error;
    return;
  }
  m_lastError.clear();
  m_coeff = std::move(outcome.coeff);
  m_hasResults = true;
  publishResults(outcome.analysis);   // emits resultsChanged
}

// Native float64 array as raw bytes (QML sees an ArrayBuffer)
static QByteArray packDoubles(const std::vector<double> &values) {
  QByteArray bytes(static_cast<qsizetype>(values.size() * sizeof(double)), Qt::Uninitialized);
  if (!values.empty())
    std::memcpy(bytes.data(), values.data(), bytes.size());
  return bytes;
}

static const double *doublesOf(const QByteArray &bytes) {
  return reinterpret_cast<const double *>(bytes.constData());
}

static qsizetype doubleCount(const QByteArray &bytes) {
  return bytes.size() / static_cast<qsizetype>(sizeof(double));
}

// {x, y} point list for the legacy QVariantList properties; xs == nullptr
// uses the sample index as x
static QVariantList pointList(const QByteArray *xs, const QByteArray &ys) {
  QVariantList list;
  const qsizetype n = doubleCount(ys);
  list.reserve(n);
  const double *y = doublesOf(ys);
  const double *x = xs ? doublesOf(*xs) : nullptr;
  for (qsizetype i = 0; i < n; ++i) {
    QVariantMap pt;
    pt["x"] = x ? x[i] : static_cast<double>(i);
    pt["y"] = y[i];
    list.append(pt);
  }
  return list;
}

QVariantList FilterEngine::magnitudeData() const {
  if (m_magnitudeList.isEmpty()) m_magnitudeList = pointList(&m_freqBuf, m_magBuf);
  return m_magnitudeList;
}
QVariantList FilterEngine::phaseData() const {
  if (m_phaseList.isEmpty()) m_phaseList = pointList(&m_freqBuf, m_phaseBuf);
  return m_phaseList;
}
QVariantList FilterEngine::groupDelayData() const {
  if (m_groupDelayList.isEmpty()) m_groupDelayList = pointList(&m_freqBuf, m_gdBuf);
  return m_groupDelayList;
}
QVariantList FilterEngine::impulseData() const {
  if (m_impulseList.isEmpty()) m_impulseList = pointList(nullptr, m_impulseBuf);
  return m_impulseList;
}
QVariantList FilterEngine::stepData() const {
  if (m_stepList.isEmpty()) m_stepList = pointList(nullptr, m_stepBuf);
  return m_stepList;
}

void FilterEngine::publishResults(const dsp::AnalysisResult &r) {
  m_magnitudeList.clear();
  m_phaseList.clear();
  m_groupDelayList.clear();
  m_impulseList.clear();
  m_stepList.clear();
  m_poleZeroData.clear();

  const size_t n = r.frequencyResponse.size();
  std::vector<double> freq(n), mag(n), phase(n), gd(n);
  double maxMag = -1e9;
  double peakF = 0.0;
  for (size_t i = 0; i < n; ++i) {
    const auto &p = r.frequencyResponse[i];
    freq[i] = p.frequency;
    mag[i] = p.magnitude;
    phase[i] = p.phase;
    gd[i] = p.groupDelay;
    if (p.magnitude > maxMag) {
      maxMag = p.magnitude;
      peakF = p.frequency;
    }
  }
  m_freqBuf = packDoubles(freq);
  m_magBuf = packDoubles(mag);
  m_phaseBuf = packDoubles(phase);
  m_gdBuf = packDoubles(gd);
  m_impulseBuf = packDoubles(r.impulseResponse);
  m_stepBuf = packDoubles(r.stepResponse);

  m_peakGainDb = (maxMag > -250.0) ? maxMag : 0.0;
  m_peakFreqHz = peakF;

  // DC / Steady-State Transfer Function
  auto hDc = m_coeff.evaluate(0.0);
  m_steadyStateGain = hDc.real();

  double stepPeak = 0.0;
  int peakIdx = 0;
  for (size_t i = 0; i < r.stepResponse.size(); ++i) {
    const double y = r.stepResponse[i];
    if (std::abs(y) > std::abs(stepPeak)) {
      stepPeak = y;
      peakIdx = static_cast<int>(i);
    }
  }

  // Calculate stepinfo metrics (MATLAB equivalent)
  double yFinal = r.stepResponse.empty() ? 0.0 : r.stepResponse.back();
  double overshoot = 0.0;
  if (std::abs(yFinal) > 1e-6) {
    overshoot = ((stepPeak - yFinal) / std::abs(yFinal)) * 100.0;
    if (overshoot < 0.0) overshoot = 0.0;
  }

  int rise10 = -1, rise90 = -1;
  int settlingSamples = 0;
  if (std::abs(yFinal) > 1e-6) {
    double t10 = 0.1 * yFinal;
    double t90 = 0.9 * yFinal;
    for (size_t i = 0; i < r.stepResponse.size(); ++i) {
      double y = r.stepResponse[i];
      if (rise10 < 0 && (yFinal >= 0 ? y >= t10 : y <= t10)) rise10 = static_cast<int>(i);
      if (rise90 < 0 && (yFinal >= 0 ? y >= t90 : y <= t90)) rise90 = static_cast<int>(i);
    }
    const double tol = 0.02 * std::abs(yFinal);
    for (int i = static_cast<int>(r.stepResponse.size()) - 1; i >= 0; --i) {
      if (std::abs(r.stepResponse[i] - yFinal) > tol) {
        settlingSamples = i + 1;
        break;
      }
    }
  }

  m_stepMetrics.clear();
  m_stepMetrics["steadyState"] = yFinal;
  m_stepMetrics["peakValue"] = stepPeak;
  m_stepMetrics["peakTime"] = peakIdx;
  m_stepMetrics["overshootPercent"] = overshoot;
  m_stepMetrics["riseTimeSamples"] = (rise90 >= 0 && rise10 >= 0) ? (rise90 - rise10) : 0;
  m_stepMetrics["settlingTimeSamples"] = settlingSamples;

  // Stability margin
  double maxR = 0.0;
  for (const auto &p : r.poles) {
    double rad = std::abs(p);
    if (rad > maxR) maxR = rad;
  }
  m_stabilityMargin = 1.0 - maxR;

  // Calculate multiplicities for poles (MATLAB zplane convention)
  const size_t numPoles = r.poles.size();
  std::vector<int> poleMult(numPoles, 1);
  std::vector<bool> polePrimary(numPoles, true);
  for (size_t i = 0; i < numPoles; ++i) {
    if (!polePrimary[i]) continue;
    int count = 1;
    for (size_t j = i + 1; j < numPoles; ++j) {
      if (std::abs(r.poles[i] - r.poles[j]) < 1e-7) {
        count++;
        polePrimary[j] = false;
      }
    }
    poleMult[i] = count;
  }

  for (size_t i = 0; i < numPoles; ++i) {
    QVariantMap pt;
    pt["re"] = r.poles[i].real();
    pt["im"] = r.poles[i].imag();
    pt["kind"] = "pole";
    pt["multiplicity"] = poleMult[i];
    pt["isPrimary"] = static_cast<bool>(polePrimary[i]);
    m_poleZeroData.append(pt);
  }

  // Calculate multiplicities for zeros (MATLAB zplane convention)
  const size_t numZeros = r.zeros.size();
  std::vector<int> zeroMult(numZeros, 1);
  std::vector<bool> zeroPrimary(numZeros, true);
  for (size_t i = 0; i < numZeros; ++i) {
    if (!zeroPrimary[i]) continue;
    int count = 1;
    for (size_t j = i + 1; j < numZeros; ++j) {
      if (std::abs(r.zeros[i] - r.zeros[j]) < 1e-7) {
        count++;
        zeroPrimary[j] = false;
      }
    }
    zeroMult[i] = count;
  }

  for (size_t i = 0; i < numZeros; ++i) {
    QVariantMap pt;
    pt["re"] = r.zeros[i].real();
    pt["im"] = r.zeros[i].imag();
    pt["kind"] = "zero";
    pt["multiplicity"] = zeroMult[i];
    pt["isPrimary"] = static_cast<bool>(zeroPrimary[i]);
    m_poleZeroData.append(pt);
  }

  emit resultsChanged();
}

QString FilterEngine::exportCode(int format) {
  if (!m_hasResults)
    return {};
  try {
    auto fmt = static_cast<dsp::ExportFormat>(format);
    return QString::fromStdString(
        dsp::CodeExporter::generate(m_coeff, m_spec, fmt));
  } catch (const std::exception &e) {
    return QString("// Error: %1").arg(e.what());
  }
}

QString FilterEngine::filterTypeName() const {
  return QString::fromStdString(m_spec.typeName());
}
QString FilterEngine::filterResponseName() const {
  if (m_spec.isFir())
    return QString("FIR %1").arg(QString::fromStdString(m_spec.windowLabel()));
  return QString::fromStdString(m_spec.responseName());
}
QString FilterEngine::firWindowName() const {
  return QString::fromStdString(m_spec.windowName());
}

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
      if (doc.isArray())
        arr = doc.array();
      f.close();
    }
  }

  QVariantList list;
  for (const auto &val : arr) {
    list.append(val.toObject().toVariantMap());
  }
  return list;
}

void FilterEngine::copyText(const QString &text) {
  if (auto *cb = QGuiApplication::clipboard()) {
    cb->setText(text);
  }
}

void FilterEngine::reset() {
  m_spec = dsp::FilterSpec{};
  m_iirOrder = m_spec.order;
  m_firOrder = kDefaultFirOrder;
  emit specChanged();
  design();
}

bool FilterEngine::savePreset(const QString &name) {
  if (name.trimmed().isEmpty())
    return false;
  QFile f(presetsFilePath());
  QJsonArray arr;
  if (f.open(QIODevice::ReadOnly)) {
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (doc.isArray())
      arr = doc.array();
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
  p["firWindow"] = static_cast<int>(m_spec.firWindow);
  p["firWindowParam"] = m_spec.firWindowParam;
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
  if (!replaced)
    arr.append(p);

  if (f.open(QIODevice::WriteOnly)) {
    f.write(QJsonDocument(arr).toJson());
    f.close();
    return true;
  }
  return false;
}

bool FilterEngine::deletePreset(const QString &name) {
  QFile f(presetsFilePath());
  QJsonArray arr;
  if (f.open(QIODevice::ReadOnly)) {
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (doc.isArray())
      arr = doc.array();
    f.close();
  } else {
    return false;
  }

  QJsonArray newArr;
  for (const auto &val : arr) {
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

bool FilterEngine::applyPreset(const QString &name) {
  QFile f(presetsFilePath());
  QJsonArray arr;
  if (f.open(QIODevice::ReadOnly)) {
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (doc.isArray())
      arr = doc.array();
    f.close();
  } else {
    arr = defaultPresets();
  }

  for (const auto &val : arr) {
    QJsonObject o = val.toObject();
    if (o["name"].toString() == name) {
      // applySpec validates every field, so a hand-edited or older preset
      // file cannot push an out-of-range enum or order into the designer
      QVariantMap spec;
      spec["filterType"] = o["type"].toInt();
      spec["filterResponse"] = o["response"].toInt();
      spec["order"] = o["order"].toInt();
      spec["cutoffFreq"] = o["cutoffFreq"].toDouble();
      spec["cutoffFreq2"] = o["cutoffFreq2"].toDouble();
      spec["rippleDb"] = o["rippleDb"].toDouble();
      spec["stopbandDb"] = o["stopbandDb"].toDouble();
      spec["sampleRate"] = o["sampleRate"].toDouble(48000.0);
      spec["firWindow"] = o["firWindow"].toInt(static_cast<int>(dsp::FirWindow::Hamming));
      spec["firWindowParam"] = o["firWindowParam"].toDouble(0.5);
      applySpec(spec);
      return true;
    }
  }
  return false;
}

// ── Tutorial sharing & File I/O ──────────────────────────────────────────────

static QString tutorialsFilePath() {
    QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    return dir + "/student_tutorials.json";
}

bool FilterEngine::writeTextFile(const QString& filePath, const QString& content) {
    QString actualPath = filePath;
    if (actualPath.startsWith("file://")) {
        actualPath = QUrl(filePath).toLocalFile();
    }
    QFile f(actualPath);
    if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        f.write(content.toUtf8());
        return true;
    }
    return false;
}

QString FilterEngine::readTextFile(const QString& filePath) {
    QString actualPath = filePath;
    if (actualPath.startsWith("file://")) {
        actualPath = QUrl(filePath).toLocalFile();
    }
    QFile f(actualPath);
    if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QString::fromUtf8(f.readAll());
    }
    return "";
}

bool FilterEngine::saveTutorial(const QString& jsonString) {
    QFile f(tutorialsFilePath());
    QJsonArray arr;
    if (f.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
        if (doc.isArray()) arr = doc.array();
        f.close();
    }

    QJsonDocument doc = QJsonDocument::fromJson(jsonString.toUtf8());
    QJsonObject p = doc.object();
    QString id = p["id"].toString();

    bool replaced = false;
    for (int i = 0; i < arr.size(); ++i) {
        if (arr[i].toObject()["id"].toString() == id) {
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

QVariantList FilterEngine::loadTutorials() {
    QFile f(tutorialsFilePath());
    QJsonArray arr;
    if (f.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
        if (doc.isArray()) arr = doc.array();
        f.close();
    }
    QVariantList list;
    for (const auto& val : arr) {
        list.append(val.toObject().toVariantMap());
    }
    return list;
}

bool FilterEngine::deleteTutorial(const QString& id) {
    QFile f(tutorialsFilePath());
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
        if (val.toObject()["id"].toString() != id) {
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

QString FilterEngine::tutorialsDirectory() const {
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

bool FilterEngine::isStable() const {
    if (!m_hasResults || !m_coeff.isValid())
        return true;
    for (const auto &p : m_coeff.poles) {
        if (std::abs(p) >= 1.0)
            return false;
    }
    return true;
}

double FilterEngine::maxPoleRadius() const {
    if (!m_hasResults || !m_coeff.isValid())
        return 0.0;
    double maxR = 0.0;
    for (const auto &p : m_coeff.poles) {
        double r = std::abs(p);
        if (r > maxR)
            maxR = r;
    }
    return maxR;
}

double FilterEngine::magnitudeDbAt(double freqHz) const {
    if (!m_hasResults || !m_coeff.isValid() || m_spec.sampleRate <= 0.0)
        return 0.0;
    double omega = 2.0 * M_PI * freqHz / m_spec.sampleRate;
    if (omega < 0.0) omega = 0.0;
    if (omega > M_PI) omega = M_PI;
    auto h = m_coeff.evaluate(omega);
    double mag = std::abs(h);
    return (mag > 1e-12) ? 20.0 * std::log10(mag) : -240.0;
}

double FilterEngine::attenuationDbAt(double freqHz) const {
    return -magnitudeDbAt(freqHz);
}

double FilterEngine::passbandRippleDb(double fStart, double fEnd) const {
    if (!m_hasResults || !m_coeff.isValid() || m_spec.sampleRate <= 0.0)
        return 0.0;
    if (fStart > fEnd) std::swap(fStart, fEnd);

    double maxMag = -1e9;
    double minMag = 1e9;
    const int steps = 40;
    for (int i = 0; i <= steps; ++i) {
        double f = fStart + (fEnd - fStart) * (double(i) / steps);
        double db = magnitudeDbAt(f);
        if (db > maxMag) maxMag = db;
        if (db < minMag) minMag = db;
    }
    return (maxMag > minMag) ? (maxMag - minMag) : 0.0;
}

QVariantMap FilterEngine::evaluateResponseAt(double freqHz) const {
    QVariantMap res;
    if (!m_hasResults || !m_coeff.isValid() || m_spec.sampleRate <= 0.0) {
        res["freq"] = freqHz;
        res["magDb"] = 0.0;
        res["magLin"] = 1.0;
        res["phase"] = 0.0;
        res["phaseWrapped"] = 0.0;
        res["phaseUnwrapped"] = 0.0;
        res["groupDelay"] = 0.0;
        return res;
    }

    auto pt = dsp::FilterAnalysis::evaluatePoint(m_coeff, m_spec.sampleRate, freqHz);
    res["freq"] = pt.frequency;
    res["magDb"] = pt.magnitude;
    res["magLin"] = (pt.magnitude > -250.0) ? std::pow(10.0, pt.magnitude / 20.0) : 0.0;
    res["phase"] = pt.phase;

    double wrappedP = std::fmod(pt.phase + 180.0, 360.0);
    if (wrappedP < 0.0) wrappedP += 360.0;
    wrappedP -= 180.0;
    res["phaseWrapped"] = wrappedP;

    // Continuous unwrapped phase interpolation from verified grid
    const qsizetype count = std::min(doubleCount(m_freqBuf), doubleCount(m_phaseBuf));
    if (count > 0) {
        const double *freqs = doublesOf(m_freqBuf);
        const double *phases = doublesOf(m_phaseBuf);
        const qsizetype low = std::lower_bound(freqs, freqs + count, pt.frequency) - freqs;
        const qsizetype idx1 = std::clamp<qsizetype>(low - 1, 0, count - 1);
        const qsizetype idx2 = std::clamp<qsizetype>(low, 0, count - 1);
        if (idx1 == idx2) {
            res["phaseUnwrapped"] = phases[idx1];
        } else {
            const double f1 = freqs[idx1], f2 = freqs[idx2];
            const double t = (f2 > f1) ? (pt.frequency - f1) / (f2 - f1) : 0.0;
            res["phaseUnwrapped"] = phases[idx1] + t * (phases[idx2] - phases[idx1]);
        }
    } else {
        res["phaseUnwrapped"] = pt.phase;
    }

    res["groupDelay"] = pt.groupDelay;
    return res;
}

QVariantMap FilterEngine::evaluateLab(double passbandFreq, double stopbandFreq,
                                      double minStopbandAttenDb, double maxPassbandRippleDb,
                                      int maxOrder) const {
    QVariantMap res;
    bool stable = isStable();
    double maxR = maxPoleRadius();
    double attenStop = attenuationDbAt(stopbandFreq);
    double ripPass = passbandRippleDb(10.0, passbandFreq);
    bool stopSat = (attenStop >= minStopbandAttenDb);
    bool passSat = (ripPass <= maxPassbandRippleDb);
    bool orderSat = (m_spec.order <= maxOrder);

    int score = 0;
    if (passSat) score++;
    if (stopSat) score++;
    if (stable) score++;
    if (orderSat) score++;

    res["passbandSatisfied"] = passSat;
    res["stopbandSatisfied"] = stopSat;
    res["stabilitySatisfied"] = stable;
    res["orderSatisfied"] = orderSat;
    res["attenuationAtStop"] = attenStop;
    res["rippleInPass"] = ripPass;
    res["maxPoleRadius"] = maxR;
    res["currentOrder"] = m_spec.order;
    res["score"] = score;
    res["allPassed"] = (score == 4);
    return res;
}

QString FilterEngine::picturesDirectory() const {
    QString dir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    if (dir.isEmpty()) {
        dir = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    }
    return dir;
}

QString FilterEngine::defaultExportPlotPath(const QString &plotName) const {
    QString dir = picturesDirectory();
    QDir().mkpath(dir);
    QString cleanName = plotName;
    cleanName.replace(QRegularExpression("[^a-zA-Z0-9_-]"), "_");
    if (cleanName.isEmpty()) cleanName = "dsp_plot";
    QString timeStr = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    return dir + "/" + cleanName + "_" + timeStr + ".png";
}

bool FilterEngine::copyImageFileToClipboard(const QString &filePath) {
    QString clean = filePath;
    if (clean.startsWith("file://")) {
        clean = QUrl(filePath).toLocalFile();
    }
    QImage img(clean);
    if (img.isNull()) {
        qWarning() << "[FilterEngine] Failed to load image for clipboard:" << clean;
        return false;
    }
    QGuiApplication::clipboard()->setImage(img);
    return true;
}

bool FilterEngine::saveImageData(const QString &filePath, const QString &dataUrlOrBase64) {
    QString clean = filePath;
    if (clean.startsWith("file://")) {
        clean = QUrl(filePath).toLocalFile();
    }
    QFileInfo fi(clean);
    QDir().mkpath(fi.absolutePath());

    QString base64Str = dataUrlOrBase64;
    int commaIdx = base64Str.indexOf(',');
    if (commaIdx >= 0) {
        base64Str = base64Str.mid(commaIdx + 1);
    }
    QByteArray bytes = QByteArray::fromBase64(base64Str.toLatin1());
    if (bytes.isEmpty()) {
        return false;
    }
    QFile f(clean);
    if (!f.open(QIODevice::WriteOnly)) return false;
    f.write(bytes);
    return true;
}

