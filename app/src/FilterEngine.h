#pragma once
#include "dsp/FilterAnalysis.h"
#include "dsp/FilterCoefficients.h"
#include "dsp/FilterSpec.h"
#include <QByteArray>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QThreadPool>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>

// FilterEngine: the C++/QML bridge for the DSP library.
// Exposes filter design, analysis results, and code export to QML.
class FilterEngine : public QObject {
  Q_OBJECT

  // ── Filter spec properties ──────────────────────────────────────────────
  Q_PROPERTY(
      int filterType READ filterType WRITE setFilterType NOTIFY specChanged)
  Q_PROPERTY(int filterResponse READ filterResponse WRITE setFilterResponse
                 NOTIFY specChanged)
  Q_PROPERTY(int order READ order WRITE setOrder NOTIFY specChanged)
  Q_PROPERTY(
      double sampleRate READ sampleRate WRITE setSampleRate NOTIFY specChanged)
  Q_PROPERTY(
      double cutoffFreq READ cutoffFreq WRITE setCutoffFreq NOTIFY specChanged)
  Q_PROPERTY(double cutoffFreq2 READ cutoffFreq2 WRITE setCutoffFreq2 NOTIFY
                 specChanged)
  Q_PROPERTY(double rippleDb READ rippleDb WRITE setRippleDb NOTIFY specChanged)
  Q_PROPERTY(
      double stopbandDb READ stopbandDb WRITE setStopbandDb NOTIFY specChanged)
  Q_PROPERTY(int firWindow READ firWindow WRITE setFirWindow NOTIFY specChanged)
  Q_PROPERTY(double firWindowParam READ firWindowParam WRITE setFirWindowParam
                 NOTIFY specChanged)

  // Display names as properties so QML bindings refresh when the spec changes
  // (bindings do not track Q_INVOKABLE calls)
  Q_PROPERTY(QString typeName READ filterTypeName NOTIFY specChanged)
  Q_PROPERTY(QString responseName READ filterResponseName NOTIFY specChanged)
  Q_PROPERTY(QString windowLabel READ firWindowLabel NOTIFY specChanged)
  Q_PROPERTY(int effectiveOrder READ effectiveOrder NOTIFY specChanged)
  Q_PROPERTY(QString orderLabel READ orderLabel NOTIFY specChanged)
  Q_PROPERTY(bool windowUsesParam READ windowUsesParam NOTIFY specChanged)
  Q_PROPERTY(bool windowUsesAtten READ windowUsesAtten NOTIFY specChanged)
  // Magnitude at the cutoff edge for the current family (-3 dB, -ripple, ...)
  Q_PROPERTY(double edgeDb READ edgeDb NOTIFY specChanged)

  // ── Analysis result properties ──────────────────────────────────────────
  // Packed native-endian float64 arrays, one value per analysis point. QML
  // receives them as ArrayBuffers (wrap in Float64Array): a single copy instead
  // of thousands of {x, y} objects. Preferred by the plots.
  Q_PROPERTY(QByteArray frequencyBuffer READ frequencyBuffer NOTIFY resultsChanged)
  Q_PROPERTY(QByteArray magnitudeBuffer READ magnitudeBuffer NOTIFY resultsChanged)
  Q_PROPERTY(QByteArray phaseBuffer READ phaseBuffer NOTIFY resultsChanged)
  Q_PROPERTY(QByteArray groupDelayBuffer READ groupDelayBuffer NOTIFY resultsChanged)
  // Legacy {x, y} point lists, built only when first read after a design
  Q_PROPERTY(
      QVariantList magnitudeData READ magnitudeData NOTIFY resultsChanged)
  Q_PROPERTY(QVariantList phaseData READ phaseData NOTIFY resultsChanged)
  Q_PROPERTY(
      QVariantList groupDelayData READ groupDelayData NOTIFY resultsChanged)
  Q_PROPERTY(QVariantList poleZeroData READ poleZeroData NOTIFY resultsChanged)
  Q_PROPERTY(QVariantList impulseData READ impulseData NOTIFY resultsChanged)
  Q_PROPERTY(QVariantList stepData READ stepData NOTIFY resultsChanged)
  Q_PROPERTY(double steadyStateGain READ steadyStateGain NOTIFY resultsChanged)
  Q_PROPERTY(double peakGainDb READ peakGainDb NOTIFY resultsChanged)
  Q_PROPERTY(double peakFreqHz READ peakFreqHz NOTIFY resultsChanged)
  Q_PROPERTY(double stabilityMargin READ stabilityMargin NOTIFY resultsChanged)
  Q_PROPERTY(QVariantMap stepMetrics READ stepMetrics NOTIFY resultsChanged)
  Q_PROPERTY(bool hasResults READ hasResults NOTIFY resultsChanged)
  Q_PROPERTY(bool isFir READ isFir NOTIFY resultsChanged)
  Q_PROPERTY(int sectionCount READ sectionCount NOTIFY resultsChanged)
  Q_PROPERTY(int tapCount READ tapCount NOTIFY resultsChanged)

public:
  explicit FilterEngine(QObject *parent = nullptr);
  ~FilterEngine() override;

  // Property getters
  int filterType() const { return static_cast<int>(m_spec.type); }
  int filterResponse() const { return static_cast<int>(m_spec.response); }
  int order() const { return m_spec.order; }
  double sampleRate() const { return m_spec.sampleRate; }
  double cutoffFreq() const { return m_spec.cutoffFreq; }
  double cutoffFreq2() const { return m_spec.cutoffFreq2; }
  double rippleDb() const { return m_spec.rippleDb; }
  double stopbandDb() const { return m_spec.stopbandDb; }
  int firWindow() const { return static_cast<int>(m_spec.firWindow); }
  double firWindowParam() const { return m_spec.firWindowParam; }
  int effectiveOrder() const;
  double edgeDb() const;
  QString orderLabel() const;
  QString firWindowLabel() const { return QString::fromStdString(m_spec.windowLabel()); }
  bool windowUsesParam() const { return m_spec.isFir() && m_spec.windowUsesParam(); }
  bool windowUsesAtten() const { return m_spec.isFir() && m_spec.windowUsesAtten(); }

  QByteArray frequencyBuffer() const { return m_freqBuf; }
  QByteArray magnitudeBuffer() const { return m_magBuf; }
  QByteArray phaseBuffer() const { return m_phaseBuf; }
  QByteArray groupDelayBuffer() const { return m_gdBuf; }
  QVariantList magnitudeData() const;
  QVariantList phaseData() const;
  QVariantList groupDelayData() const;
  QVariantList poleZeroData() const { return m_poleZeroData; }
  QVariantList impulseData() const;
  QVariantList stepData() const;
  double steadyStateGain() const { return m_steadyStateGain; }
  double peakGainDb() const { return m_peakGainDb; }
  double peakFreqHz() const { return m_peakFreqHz; }
  double stabilityMargin() const { return m_stabilityMargin; }
  QVariantMap stepMetrics() const { return m_stepMetrics; }
  bool hasResults() const { return m_hasResults; }
  bool isFir() const { return m_coeff.isFir(); }
  int sectionCount() const { return static_cast<int>(m_coeff.sos.size()); }
  int tapCount() const { return static_cast<int>(m_coeff.fir.size()); }
  const dsp::FilterCoefficients& coefficients() const { return m_coeff; }

  // Property setters
  void setFilterType(int v);
  void setFilterResponse(int v);
  void setOrder(int v);
  void setSampleRate(double v);
  void setCutoffFreq(double v);
  void setCutoffFreq2(double v);
  void setRippleDb(double v);
  void setStopbandDb(double v);
  void setFirWindow(int v);
  void setFirWindowParam(double v);

  // QML-invokable methods
  Q_INVOKABLE void design();
  // Sets any subset of the spec properties (same keys as the Q_PROPERTYs)
  // and designs once, so a multi-field edit never passes through invalid
  // intermediate specs.
  Q_INVOKABLE void applySpec(const QVariantMap &spec);
  // Order to use when switching to `response`: IIR and FIR each remember
  // their last order, clamped to the family's limit.
  Q_INVOKABLE int orderFor(int response) const;
  Q_INVOKABLE int maxOrder(int response) const;
  Q_INVOKABLE QVariantMap verifyDesign();
  Q_INVOKABLE QString exportCode(int format); // 0=C, 1=C++, 2=Python, 3=JSON
  Q_INVOKABLE QString filterTypeName() const;
  Q_INVOKABLE QString filterResponseName() const;
  Q_INVOKABLE QString firWindowName() const;
  Q_INVOKABLE QStringList firWindowNames() const;

  // Converts a file-dialog URL (file:///C:/...) to a native path; plain paths pass through
  Q_INVOKABLE QString toLocalPath(const QString &urlOrPath) const;

  // Reset filter parameters to defaults
  Q_INVOKABLE void reset();

  // Base density of the frequency-analysis grid (Settings > Plot resolution)
  void setAnalysisPoints(int points);

  // Clipboard utility
  Q_INVOKABLE void copyText(const QString &text);

  // Preset persistence to local storage
  Q_INVOKABLE bool savePreset(const QString &name);
  Q_INVOKABLE QVariantList loadPresets();
  Q_INVOKABLE bool deletePreset(const QString &name);
  Q_INVOKABLE bool applyPreset(const QString &name);

  // Tutorial creator, sharing, and file I/O
  Q_INVOKABLE bool writeTextFile(const QString &filePath, const QString &content);
  Q_INVOKABLE QString readTextFile(const QString &filePath);
  Q_INVOKABLE bool saveTutorial(const QString &jsonString);
  Q_INVOKABLE QVariantList loadTutorials();
  Q_INVOKABLE bool deleteTutorial(const QString &id);
  Q_INVOKABLE QString tutorialsDirectory() const;

  // Interactive Learning & Lab Challenge Evaluator
  Q_INVOKABLE bool isStable() const;
  Q_INVOKABLE double maxPoleRadius() const;
  Q_INVOKABLE double magnitudeDbAt(double freqHz) const;
  Q_INVOKABLE double attenuationDbAt(double freqHz) const;
  Q_INVOKABLE double passbandRippleDb(double fStart, double fEnd) const;
  Q_INVOKABLE QVariantMap evaluateResponseAt(double freqHz) const;
  Q_INVOKABLE QVariantMap evaluateLab(double passbandFreq, double stopbandFreq,
                                      double minStopbandAttenDb, double maxPassbandRippleDb,
                                      int maxOrder) const;

  // Plot Image Export & System Integration
  Q_INVOKABLE QString picturesDirectory() const;
  Q_INVOKABLE QString defaultExportPlotPath(const QString &plotName) const;
  Q_INVOKABLE bool copyImageFileToClipboard(const QString &filePath);
  Q_INVOKABLE bool saveImageData(const QString &filePath, const QString &dataUrlOrBase64);

signals:
  void specChanged();
  void resultsChanged();
  void errorOccurred(const QString &message);

private:
  // One design + analysis run. Built from a spec copy so it can run on the
  // worker thread; `gen` is the spec generation it was computed from.
  struct DesignOutcome {
    quint64 gen{0};
    dsp::FilterCoefficients coeff;
    dsp::AnalysisResult analysis;
    QString error;
  };
  static DesignOutcome runDesign(const dsp::FilterSpec &spec, int points,
                                 double cutoff2, quint64 gen);

  void scheduleDesign();
  void startAsyncDesign();
  void finishAsyncDesign(DesignOutcome &&outcome);
  void designInternal();
  void applyOutcome(DesignOutcome &&outcome);
  void publishResults(const dsp::AnalysisResult &result);
  void rememberOrder();
  double analysisCutoff2() const;

  static constexpr int kDefaultFirOrder = 64;

  // Live edits (slider scrubbing, handle drags) redesign at most once per
  // frame on m_pool; discrete edits design synchronously. Results are only
  // published if newer than what is shown, so a slow run never overwrites a
  // later one.
  QTimer m_throttleTimer;
  QThreadPool m_pool;
  quint64 m_specGen{0};
  quint64 m_publishedGen{0};
  bool m_jobRunning{false};
  bool m_jobPending{false};
  QString m_lastError;

  int m_analysisPoints{3072};
  dsp::FilterSpec m_spec;
  int m_iirOrder{dsp::FilterSpec{}.order};
  int m_firOrder{kDefaultFirOrder};
  dsp::FilterCoefficients m_coeff;
  bool m_hasResults{false};

  QByteArray m_freqBuf;
  QByteArray m_magBuf;
  QByteArray m_phaseBuf;
  QByteArray m_gdBuf;
  QByteArray m_impulseBuf;
  QByteArray m_stepBuf;
  QVariantList m_poleZeroData;
  // Lazily built legacy lists; cleared whenever new results are published
  mutable QVariantList m_magnitudeList;
  mutable QVariantList m_phaseList;
  mutable QVariantList m_groupDelayList;
  mutable QVariantList m_impulseList;
  mutable QVariantList m_stepList;

  double m_steadyStateGain{1.0};
  double m_peakGainDb{0.0};
  double m_peakFreqHz{0.0};
  double m_stabilityMargin{1.0};
  QVariantMap m_stepMetrics;
};
