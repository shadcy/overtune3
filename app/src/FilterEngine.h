#pragma once
#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include "dsp/FilterSpec.h"
#include "dsp/FilterCoefficients.h"
#include "dsp/FilterAnalysis.h"

// FilterEngine: the C++/QML bridge for the DSP library.
// Exposes filter design, analysis results, and code export to QML.
class FilterEngine : public QObject {
    Q_OBJECT

    // ── Filter spec properties ──────────────────────────────────────────────
    Q_PROPERTY(int    filterType     READ filterType     WRITE setFilterType     NOTIFY specChanged)
    Q_PROPERTY(int    filterResponse READ filterResponse WRITE setFilterResponse NOTIFY specChanged)
    Q_PROPERTY(int    order          READ order          WRITE setOrder          NOTIFY specChanged)
    Q_PROPERTY(double sampleRate     READ sampleRate     WRITE setSampleRate     NOTIFY specChanged)
    Q_PROPERTY(double cutoffFreq     READ cutoffFreq     WRITE setCutoffFreq     NOTIFY specChanged)
    Q_PROPERTY(double cutoffFreq2    READ cutoffFreq2    WRITE setCutoffFreq2    NOTIFY specChanged)
    Q_PROPERTY(double rippleDb       READ rippleDb       WRITE setRippleDb       NOTIFY specChanged)
    Q_PROPERTY(double stopbandDb     READ stopbandDb     WRITE setStopbandDb     NOTIFY specChanged)

    // ── Analysis result properties ──────────────────────────────────────────
    Q_PROPERTY(QVariantList magnitudeData  READ magnitudeData  NOTIFY resultsChanged)
    Q_PROPERTY(QVariantList phaseData      READ phaseData      NOTIFY resultsChanged)
    Q_PROPERTY(QVariantList groupDelayData READ groupDelayData NOTIFY resultsChanged)
    Q_PROPERTY(QVariantList poleZeroData   READ poleZeroData   NOTIFY resultsChanged)
    Q_PROPERTY(QVariantList impulseData    READ impulseData    NOTIFY resultsChanged)
    Q_PROPERTY(QVariantList stepData       READ stepData       NOTIFY resultsChanged)
    Q_PROPERTY(bool         hasResults     READ hasResults     NOTIFY resultsChanged)

public:
    explicit FilterEngine(QObject* parent = nullptr);

    // Property getters
    int    filterType()     const { return static_cast<int>(m_spec.type); }
    int    filterResponse() const { return static_cast<int>(m_spec.response); }
    int    order()          const { return m_spec.order; }
    double sampleRate()     const { return m_spec.sampleRate; }
    double cutoffFreq()     const { return m_spec.cutoffFreq; }
    double cutoffFreq2()    const { return m_spec.cutoffFreq2; }
    double rippleDb()       const { return m_spec.rippleDb; }
    double stopbandDb()     const { return m_spec.stopbandDb; }

    QVariantList magnitudeData()  const { return m_magnitudeData; }
    QVariantList phaseData()      const { return m_phaseData; }
    QVariantList groupDelayData() const { return m_groupDelayData; }
    QVariantList poleZeroData()   const { return m_poleZeroData; }
    QVariantList impulseData()    const { return m_impulseData; }
    QVariantList stepData()       const { return m_stepData; }
    bool         hasResults()     const { return m_hasResults; }

    // Property setters
    void setFilterType    (int v);
    void setFilterResponse(int v);
    void setOrder         (int v);
    void setSampleRate    (double v);
    void setCutoffFreq    (double v);
    void setCutoffFreq2   (double v);
    void setRippleDb      (double v);
    void setStopbandDb    (double v);

    // QML-invokable methods
    Q_INVOKABLE void   design();
    Q_INVOKABLE QString exportCode(int format);  // 0=C, 1=C++, 2=Python, 3=JSON
    Q_INVOKABLE QString filterTypeName()     const;
    Q_INVOKABLE QString filterResponseName() const;

    // Reset filter parameters to defaults
    Q_INVOKABLE void         reset();

    // Clipboard utility
    Q_INVOKABLE void         copyText(const QString& text);

    // Preset persistence to local storage
    Q_INVOKABLE bool         savePreset(const QString& name);
    Q_INVOKABLE QVariantList loadPresets();
    Q_INVOKABLE bool         deletePreset(const QString& name);
    Q_INVOKABLE bool         applyPreset(const QString& name);

signals:
    void specChanged();
    void resultsChanged();
    void errorOccurred(const QString& message);

private:
    void publishResults(const dsp::AnalysisResult& result);

    dsp::FilterSpec        m_spec;
    dsp::FilterCoefficients m_coeff;
    bool                   m_hasResults{false};

    QVariantList m_magnitudeData;
    QVariantList m_phaseData;
    QVariantList m_groupDelayData;
    QVariantList m_poleZeroData;
    QVariantList m_impulseData;
    QVariantList m_stepData;
};
