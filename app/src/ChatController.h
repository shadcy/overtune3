#pragma once

#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QObject>
#include <QPointer>
#include <QString>
#include <QVariantList>

class FilterEngine;
class QNetworkReply;

class ChatController final : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString modelName READ modelName WRITE setModelName NOTIFY settingsChanged)
  Q_PROPERTY(bool apiKeyConfigured READ apiKeyConfigured NOTIFY settingsChanged)
  Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
  Q_PROPERTY(QVariantList messages READ messages NOTIFY messagesChanged)

public:
  explicit ChatController(FilterEngine *engine, QObject *parent = nullptr);

  QString modelName() const { return m_modelName; }
  bool apiKeyConfigured() const;
  bool busy() const { return m_busy; }
  QVariantList messages() const { return m_messages; }

  void setModelName(const QString &model);

  Q_INVOKABLE void saveApiKey(const QString &key);
  Q_INVOKABLE void clearApiKey();
  Q_INVOKABLE void sendMessage(const QString &text);
  Q_INVOKABLE void cancelRequest();
  Q_INVOKABLE void clearConversation();

signals:
  void settingsChanged();
  void busyChanged();
  void messagesChanged();
  void requestFailed(const QString &message);

private:
  QString apiKey() const;
  void appendMessage(const QString &role, const QString &content,
                     const QVariantList &artifacts = {}, int plotMode = -1);
  void sendRequest();
  bool retryWithSmallerContext(const QString &errorText);
  void finishReply(QNetworkReply *reply);
  void setBusy(bool value);

  FilterEngine *m_engine{};
  QNetworkAccessManager m_network;
  QPointer<QNetworkReply> m_currentReply;
  QString m_modelName;
  QString m_sessionKey;
  QVariantList m_messages;
  QJsonArray m_history;
  QVariantList m_pendingArtifacts;
  bool m_busy{false};
  bool m_disableTools{false};
  int m_toolRounds{0};
  int m_variantCount{0};
  int m_promptTokenBudget{10000};
  int m_contextRetries{0};
  int m_suggestedPlotMode{-1};
  bool m_showCurrentArtifact{false};
  bool m_isComparisonRequest{false};
  QString m_requestedFamily;
};

