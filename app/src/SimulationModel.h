#pragma once
#include <QObject>
#include <QVariantList>
#include <QString>

// Handles signal simulation: apply filter to loaded signal data
class SimulationModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList inputSignal  READ inputSignal  NOTIFY dataChanged)
    Q_PROPERTY(QVariantList outputSignal READ outputSignal NOTIFY dataChanged)
    Q_PROPERTY(bool         hasData      READ hasData      NOTIFY dataChanged)
    Q_PROPERTY(QString      signalLabel  READ signalLabel  NOTIFY dataChanged)

public:
    explicit SimulationModel(QObject* parent = nullptr);

    QVariantList inputSignal()  const { return m_input; }
    QVariantList outputSignal() const { return m_output; }
    bool         hasData()      const { return !m_input.isEmpty(); }
    QString      signalLabel()  const { return m_label; }

    Q_INVOKABLE void loadWav(const QString& path);
    Q_INVOKABLE void loadCsv(const QString& path, int column = 0);
    Q_INVOKABLE void generateSine(double freq, double sampleRate, double durationSec);
    Q_INVOKABLE void generateChirp(double f0, double f1, double sampleRate, double durationSec);
    Q_INVOKABLE void applyFilter(QObject* enginePtr);
    Q_INVOKABLE void clear();

signals:
    void dataChanged();
    void errorOccurred(const QString& message);

private:
    void publish(const std::vector<double>& input);

    QVariantList m_input;
    QVariantList m_output;
    QString      m_label;
    std::vector<double> m_rawInput;
};
