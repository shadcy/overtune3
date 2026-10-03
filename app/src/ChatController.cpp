#include "ChatController.h"

#include "ChatPromptBudget.h"
#include "FilterEngine.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>
#include <QSettings>
#include <QUrl>

#include <algorithm>

#ifdef Q_OS_WIN
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <wincrypt.h>
#endif

namespace {
constexpr auto kSettingsOrg = "Overtune";
constexpr auto kSettingsApp = "Overtune3";
constexpr auto kModelSetting = "ai/openRouterModel";
constexpr auto kKeySetting = "ai/openRouterKeyDpapi";
constexpr auto kEndpoint = "https://openrouter.ai/api/v1/chat/completions";

QString protectKey(const QString &key) {
#ifdef Q_OS_WIN
  const QByteArray bytes = key.toUtf8();
  DATA_BLOB input{static_cast<DWORD>(bytes.size()),
                  reinterpret_cast<BYTE *>(const_cast<char *>(bytes.constData()))};
  DATA_BLOB output{};
  if (!CryptProtectData(&input, L"Overtune OpenRouter key", nullptr, nullptr,
                        nullptr, CRYPTPROTECT_UI_FORBIDDEN, &output))
    return {};
  const QByteArray encrypted(reinterpret_cast<const char *>(output.pbData),
                             static_cast<qsizetype>(output.cbData));
  LocalFree(output.pbData);
  return QString::fromLatin1(encrypted.toBase64());
#else
  Q_UNUSED(key)
  return {};
#endif
}

QString unprotectKey(const QString &stored) {
#ifdef Q_OS_WIN
  const QByteArray encrypted = QByteArray::fromBase64(stored.toLatin1());
  if (encrypted.isEmpty()) return {};
  DATA_BLOB input{static_cast<DWORD>(encrypted.size()),
                  reinterpret_cast<BYTE *>(const_cast<char *>(encrypted.constData()))};
  DATA_BLOB output{};
  if (!CryptUnprotectData(&input, nullptr, nullptr, nullptr, nullptr,
                          CRYPTPROTECT_UI_FORBIDDEN, &output))
    return {};
  const QString key = QString::fromUtf8(reinterpret_cast<const char *>(output.pbData),
                                        static_cast<qsizetype>(output.cbData));
  SecureZeroMemory(output.pbData, output.cbData);
  LocalFree(output.pbData);
  return key;
#else
  Q_UNUSED(stored)
  return {};
#endif
}

QJsonObject variantTool() {
  QJsonObject schema;
  schema["type"] = "object";
  schema["properties"] = QJsonObject{
      {"response", QJsonObject{{"type", "string"},
          {"enum", QJsonArray{"butterworth", "chebyshev_i", "chebyshev_ii", "elliptic", "bessel"}},
          {"description", "Response family to calculate using the current filter's topology and frequency specifications."}}},
      {"order", QJsonObject{{"type", "integer"}, {"minimum", 1}, {"maximum", 16},
          {"description", "Filter order. The DSP engine validates family-specific limits."}}}};
  schema["required"] = QJsonArray{"response", "order"};
  schema["additionalProperties"] = false;
  return QJsonObject{
      {"type", "function"},
      {"function", QJsonObject{
          {"name", "analyze_filter_variant"},
          {"description", "Design and analyze a filter variant while keeping the active topology, cutoff frequencies, sample rate, ripple, and attenuation unchanged. Returns authoritative SOS, pole-zero, verifier, frequency, phase, group-delay, impulse, and step-response artifacts. Use this for any quantitative or plotted comparison; never fabricate response data."},
          {"parameters", schema}}}};
}

QString roleContent(const QJsonValue &content) {
  if (content.isString()) return content.toString();
  if (!content.isArray()) return {};
  QStringList parts;
  for (const auto &part : content.toArray())
    if (part.isObject()) parts.append(part.toObject().value("text").toString());
  return parts.join(QLatin1Char('\n'));
}
}

ChatController::ChatController(FilterEngine *engine, QObject *parent)
    : QObject(parent), m_engine(engine) {
  QSettings settings(kSettingsOrg, kSettingsApp);
  m_modelName = settings.value(kModelSetting).toString();
  connect(&m_network, &QNetworkAccessManager::finished,
          this, &ChatController::finishReply);
}

bool ChatController::apiKeyConfigured() const {
  return !apiKey().isEmpty();
}

void ChatController::setModelName(const QString &model) {
  const QString normalized = model.trimmed();
  if (normalized == m_modelName) return;
  m_modelName = normalized.left(160);
  m_promptTokenBudget = 10000;
  QSettings settings(kSettingsOrg, kSettingsApp);
  if (m_modelName.isEmpty()) settings.remove(kModelSetting);
  else settings.setValue(kModelSetting, m_modelName);
  emit settingsChanged();
}

void ChatController::saveApiKey(const QString &key) {
  const QString normalized = key.trimmed();
  if (normalized.isEmpty()) return;
#ifdef Q_OS_WIN
  const QString encrypted = protectKey(normalized);
  if (encrypted.isEmpty()) {
    emit requestFailed(QStringLiteral("Windows could not protect this key. It was kept in memory only."));
    m_sessionKey = normalized;
  } else {
    QSettings(kSettingsOrg, kSettingsApp).setValue(kKeySetting, encrypted);
    m_sessionKey.clear();
  }
#else
  m_sessionKey = normalized;
#endif
  emit settingsChanged();
}

void ChatController::clearApiKey() {
  m_sessionKey.clear();
  QSettings settings(kSettingsOrg, kSettingsApp);
  settings.remove(kKeySetting);
  emit settingsChanged();
}

QString ChatController::apiKey() const {
  if (!m_sessionKey.isEmpty()) return m_sessionKey;
#ifdef Q_OS_WIN
  const QString stored = QSettings(kSettingsOrg, kSettingsApp).value(kKeySetting).toString();
  if (!stored.isEmpty()) return unprotectKey(stored);
#endif
  return qEnvironmentVariable("OPENROUTER_API_KEY");
}

void ChatController::appendMessage(const QString &role, const QString &content,
                                   const QVariantList &artifacts, int plotMode) {
  m_messages.append(QVariantMap{{QStringLiteral("role"), role},
                                {QStringLiteral("content"), content},
                                {QStringLiteral("artifacts"), artifacts},
                                {QStringLiteral("plotMode"), plotMode}});
  emit messagesChanged();
}

void ChatController::sendMessage(const QString &text) {
  const QString prompt = text.trimmed();
  if (prompt.isEmpty() || m_busy) return;
  if (m_modelName.trimmed().isEmpty()) {
    emit requestFailed(QStringLiteral("Enter an OpenRouter model ID in Settings."));
    return;
  }
  if (apiKey().isEmpty()) {
    emit requestFailed(QStringLiteral("Add an OpenRouter API key in Settings to start chatting."));
    return;
  }
  m_toolRounds = 0;
  m_variantCount = 0;
  m_contextRetries = 0;
  m_disableTools = false;
  const QString lowerPrompt = prompt.toLower();

  // Detect if user is specifically requesting a comparison
  m_isComparisonRequest = lowerPrompt.contains(QStringLiteral("compare")) ||
                          lowerPrompt.contains(QStringLiteral(" vs ")) ||
                          lowerPrompt.contains(QStringLiteral(" versus ")) ||
                          lowerPrompt.contains(QStringLiteral("against")) ||
                          lowerPrompt.contains(QStringLiteral("difference"));

  // Check if prompt specifically targets another family
  m_requestedFamily.clear();
  if (lowerPrompt.contains(QStringLiteral("elliptic")) || lowerPrompt.contains(QStringLiteral("cauer")))
    m_requestedFamily = QStringLiteral("elliptic");
  else if (lowerPrompt.contains(QStringLiteral("chebyshev")) || lowerPrompt.contains(QStringLiteral("cheby")))
    m_requestedFamily = QStringLiteral("chebyshev");
  else if (lowerPrompt.contains(QStringLiteral("bessel")) || lowerPrompt.contains(QStringLiteral("thomson")))
    m_requestedFamily = QStringLiteral("bessel");
  else if (lowerPrompt.contains(QStringLiteral("butterworth")))
    m_requestedFamily = QStringLiteral("butterworth");

  m_showCurrentArtifact = QRegularExpression(
      QStringLiteral("\\b(plot|graph|response|frequency|phase|magnitude|group delay|pole|zero|impulse|step)\\b"))
      .match(lowerPrompt).hasMatch();
  m_suggestedPlotMode = lowerPrompt.contains(QStringLiteral("pole")) || lowerPrompt.contains(QStringLiteral("zero")) ? 3
      : lowerPrompt.contains(QStringLiteral("impulse")) ? 4
      : lowerPrompt.contains(QStringLiteral("step")) ? 5
      : lowerPrompt.contains(QStringLiteral("delay")) ? 2
      : lowerPrompt.contains(QStringLiteral("phase")) ? 1 : 0;
  m_pendingArtifacts.clear();
  appendMessage(QStringLiteral("user"), prompt);
  m_history.append(QJsonObject{{"role", "user"}, {"content", prompt}});
  while (m_history.size() > 24) {
    m_history.removeAt(0);
    while (!m_history.isEmpty() && m_history.first().toObject().value("role").toString() != "user")
      m_history.removeAt(0);
  }
  setBusy(true);
  sendRequest();
}

void ChatController::cancelRequest() {
  if (m_currentReply) {
    m_currentReply->abort();
    m_currentReply->deleteLater();
    m_currentReply = nullptr;
  }
  m_pendingArtifacts.clear();
  if (m_busy) {
    appendMessage(QStringLiteral("assistant"), QStringLiteral("Request canceled by user."));
    setBusy(false);
  }
}

void ChatController::clearConversation() {
  if (m_busy) return;
  m_history = {};
  m_messages.clear();
  emit messagesChanged();
}

void ChatController::setBusy(bool value) {
  if (m_busy == value) return;
  m_busy = value;
  emit busyChanged();
}

void ChatController::sendRequest() {
  auto makeSystemMessage = [this](int artifactPoints, bool includeArtifact) {
    const QString artifactJson = includeArtifact && m_engine
        ? m_engine->analysisArtifactsJson(artifactPoints) : QStringLiteral("{}");
    QString system = QStringLiteral(
        "You are Omi, the DSP study assistant in Overtune. Give clear, useful explanations that connect filter behavior to the underlying signal and equations. "
        "The attached JSON is authoritative output computed by Overtune's DSP engine, not model-generated data. Its schema is versioned. "
        "For a request to change or compare filter settings, call analyze_filter_variant and use only its returned artifacts; do not estimate, interpolate, or invent samples. "
        "Explain what the plots show before adding detail. When comparing variants, describe the visible magnitude, phase, delay, pole-zero, or time-domain differences and tie them to the requested change. Keep prose focused, but explain causal steps rather than only giving a conclusion. "
        "Explain that changes apply to the active topology and fixed specifications. Distinguish facts from qualitative expectations. "
        "When discussing stability, use the verifier fields and pole radii. Never call a filter robust or exact solely from order. "
        "Use Markdown for headings, lists, and tables. Write equations with standard LaTeX delimiters such as $H(z)=B(z)/A(z)$ or $$H(e^{j\\omega})$$. "
        "If verification.specificationMet is false, state that directly. Current design artifact follows:\n%1")
        .arg(artifactJson);
    if (m_disableTools)
      system += QStringLiteral("\nThis model does not support calculation tools in this request. Give qualitative explanations only; do not claim to have computed a comparison or provide invented samples.");
    return QJsonObject{{QStringLiteral("role"), QStringLiteral("system")},
                       {QStringLiteral("content"), system}};
  };

  const int usableBudget = std::max(1024, m_promptTokenBudget - 500);
  QJsonObject systemMessage = makeSystemMessage(m_contextRetries ? 32 : 96, true);
  auto fit = chat::ChatPromptBudget::fitHistory(systemMessage, m_history, usableBudget);
  int droppedTurns = fit.droppedTurns;
  if (fit.estimatedTokens > usableBudget) {
    systemMessage = makeSystemMessage(32, true);
    fit = chat::ChatPromptBudget::fitHistory(systemMessage, fit.history, usableBudget);
    droppedTurns += fit.droppedTurns;
  }
  if (fit.estimatedTokens > usableBudget) {
    systemMessage = makeSystemMessage(32, false);
    fit = chat::ChatPromptBudget::fitHistory(systemMessage, fit.history, usableBudget);
    droppedTurns += fit.droppedTurns;
  }
  if (droppedTurns > 0) {
    systemMessage[QStringLiteral("content")] =
        systemMessage.value(QStringLiteral("content")).toString() +
        QStringLiteral("\nEarlier conversation turns were omitted to fit this model's context window. Answer the latest request using the supplied current data.");
    fit = chat::ChatPromptBudget::fitHistory(systemMessage, fit.history, usableBudget);
  }
  if (fit.estimatedTokens > usableBudget) {
    const QString details = QStringLiteral(
        "This message is too large for the selected model's context window. Shorten it or choose a model with a larger context.");
    appendMessage(QStringLiteral("assistant"), details);
    setBusy(false);
    emit requestFailed(details);
    return;
  }
  m_history = fit.history;
  QJsonArray messages{systemMessage};
  for (const auto &entry : m_history) messages.append(entry);

  QJsonObject body;
  body["model"] = m_modelName;
  body["messages"] = messages;
  if (!m_disableTools) {
    body["tools"] = QJsonArray{variantTool()};
    body["tool_choice"] = m_toolRounds < 2 ? QJsonValue("auto") : QJsonValue("none");
  }
  body["temperature"] = 0.25;
  body["max_tokens"] = 1400;

  QNetworkRequest request{QUrl(QString::fromLatin1(kEndpoint))};
  request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
  request.setRawHeader("Authorization", QByteArrayLiteral("Bearer ") + apiKey().toUtf8());
  request.setRawHeader("HTTP-Referer", "https://github.com/shadcy/overtune3");
  request.setRawHeader("X-OpenRouter-Title", "Overtune 3");
  request.setTransferTimeout(60000);
  m_currentReply = m_network.post(request, QJsonDocument(body).toJson(QJsonDocument::Compact));
}

bool ChatController::retryWithSmallerContext(const QString &errorText) {
  const int providerLimit = chat::ChatPromptBudget::providerPromptLimit(errorText);
  if (providerLimit <= 0 || m_contextRetries >= 2) return false;
  ++m_contextRetries;
  m_promptTokenBudget = chat::ChatPromptBudget::reducedBudget(m_promptTokenBudget, providerLimit);
  sendRequest();
  return true;
}

void ChatController::finishReply(QNetworkReply *reply) {
  if (reply == m_currentReply) {
    m_currentReply = nullptr;
  }
  if (!m_busy) {
    reply->deleteLater();
    return;
  }
  const QByteArray payload = reply->readAll();
  const auto networkError = reply->error();
  const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
  reply->deleteLater();

  QJsonParseError parseError{};
  const QJsonDocument doc = QJsonDocument::fromJson(payload, &parseError);
  if (networkError != QNetworkReply::NoError || !doc.isObject()) {
    QString details;
    if (doc.isObject()) details = doc.object().value("error").toObject().value("message").toString();
    if (details.isEmpty()) details = QString::fromUtf8(payload.left(320)).trimmed();
    if (details.isEmpty()) details = QStringLiteral("Network error (%1): %2").arg(status).arg(reply->errorString());
    if (retryWithSmallerContext(details)) return;
    const bool contextLimit = chat::ChatPromptBudget::providerPromptLimit(details) > 0;
    if (contextLimit) {
      details = QStringLiteral("This conversation still exceeds the selected model's context window after trimming older turns. Clear some history or choose a model with a larger context.");
    }
    if ((status == 400 || status == 422) && !m_disableTools && !contextLimit) {
      m_disableTools = true;
      m_toolRounds = 0;
      sendRequest();
      return;
    }
    appendMessage(QStringLiteral("assistant"), QStringLiteral("Request failed: %1").arg(details));
    setBusy(false);
    emit requestFailed(details);
    return;
  }

  const QJsonArray choices = doc.object().value("choices").toArray();
  if (choices.isEmpty()) {
    const QString error = doc.object().value("error").toObject().value("message").toString();
    if (retryWithSmallerContext(error)) return;
    const QString details = chat::ChatPromptBudget::providerPromptLimit(error) > 0
        ? QStringLiteral("This conversation still exceeds the selected model's context window after trimming older turns. Clear some history or choose a model with a larger context.")
        : (error.isEmpty() ? QStringLiteral("The model returned no response.") : error);
    appendMessage(QStringLiteral("assistant"), QStringLiteral("Request failed: %1").arg(details));
    setBusy(false);
    emit requestFailed(details);
    return;
  }

  const QJsonObject message = choices.first().toObject().value("message").toObject();
  const QJsonArray calls = message.value("tool_calls").toArray();
  if (!calls.isEmpty() && m_toolRounds < 2) {
    ++m_toolRounds;
    QJsonArray boundedCalls;
    for (int i = 0; i < calls.size() && i < 3; ++i) boundedCalls.append(calls.at(i));
    QJsonObject assistantToolMessage = message;
    assistantToolMessage["tool_calls"] = boundedCalls;
    m_history.append(assistantToolMessage);
    for (int i = 0; i < boundedCalls.size(); ++i) {
      const QJsonObject call = boundedCalls.at(i).toObject();
      const QJsonObject function = call.value("function").toObject();
      const QJsonObject arguments = QJsonDocument::fromJson(
          function.value("arguments").toString().toUtf8()).object();
      const QString family = arguments.value("response").toString();
      const int order = arguments.value("order").toInt();
      QString artifactText;
      if (m_variantCount >= 3) {
        artifactText = QStringLiteral("{\"error\":\"This reply reached the three-variant analysis limit.\"}");
      } else {
        ++m_variantCount;
        artifactText = m_engine
            ? m_engine->analyzeVariantJson(order, family, 64)
            : QStringLiteral("{\"error\":\"DSP engine is unavailable.\"}");
      }
      const QJsonDocument artifactDoc = QJsonDocument::fromJson(artifactText.toUtf8());
      const QJsonObject artifact = artifactDoc.object();
      if (!artifact.contains("error")) {
        const QJsonObject spec = artifact.value("specification").toObject();
        QVariantMap displayArtifact;
        displayArtifact["title"] = QStringLiteral("%1, order %2")
            .arg(spec.value("response").toString()).arg(spec.value("order").toInt());
        displayArtifact["data"] = artifact.toVariantMap();

        // Only include the current design if user explicitly requested a comparison:
        if (m_isComparisonRequest && m_pendingArtifacts.isEmpty() && m_engine) {
          const QJsonObject current = QJsonDocument::fromJson(
              m_engine->analysisArtifactsJson(320).toUtf8()).object();
          const QJsonObject currentSpec = current.value("specification").toObject();
          if (currentSpec.value("response").toString() != spec.value("response").toString() ||
              currentSpec.value("order").toInt() != spec.value("order").toInt()) {
            m_pendingArtifacts.append(QVariantMap{
                {QStringLiteral("title"), QStringLiteral("Current: %1, order %2")
                    .arg(currentSpec.value("response").toString())
                    .arg(currentSpec.value("order").toInt())},
                {QStringLiteral("data"), current.toVariantMap()}});
          }
        }

        m_pendingArtifacts.append(displayArtifact);
      }
      QJsonObject toolResult{{"role", "tool"},
                             {"tool_call_id", call.value("id")},
                             {"name", function.value("name")},
                             {"content", artifactText}};
      m_history.append(toolResult);
    }
    sendRequest();
    return;
  }

  const QString content = roleContent(message.value("content")).trimmed();
  const QString answer = content.isEmpty()
      ? QStringLiteral("The selected model returned an empty message. Try again or choose a different model.")
      : content;
  m_history.append(QJsonObject{{"role", "assistant"}, {"content", answer}});

  // If tool was not called, only show the current filter artifact if the user didn't ask about a different filter family:
  if (m_showCurrentArtifact && m_pendingArtifacts.isEmpty() && m_engine) {
    const QJsonObject current = QJsonDocument::fromJson(
        m_engine->analysisArtifactsJson(320).toUtf8()).object();
    if (!current.isEmpty()) {
      const QJsonObject spec = current.value("specification").toObject();
      const QString currentFamily = spec.value("response").toString().toLower();
      if (m_requestedFamily.isEmpty() || currentFamily.contains(m_requestedFamily)) {
        m_pendingArtifacts.append(QVariantMap{
            {QStringLiteral("title"), QStringLiteral("Current: %1, order %2")
                .arg(spec.value("response").toString()).arg(spec.value("order").toInt())},
            {QStringLiteral("data"), current.toVariantMap()}});
      }
    }
  }
  appendMessage(QStringLiteral("assistant"), answer, m_pendingArtifacts, m_suggestedPlotMode);
  m_pendingArtifacts.clear();
  setBusy(false);
}
