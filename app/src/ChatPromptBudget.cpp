#include "ChatPromptBudget.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>

#include <algorithm>

namespace chat {
namespace {

QJsonArray combinedMessages(const QJsonObject &systemMessage,
                            const QJsonArray &history) {
  QJsonArray messages{systemMessage};
  for (const auto &message : history) messages.append(message);
  return messages;
}

int nextUserMessage(const QJsonArray &history) {
  for (qsizetype i = 1; i < history.size(); ++i) {
    if (history.at(i).toObject().value(QStringLiteral("role")).toString() ==
        QStringLiteral("user"))
      return static_cast<int>(i);
  }
  return -1;
}

} // namespace

int ChatPromptBudget::estimateTokens(const QJsonArray &messages) {
  const auto encoded = QJsonDocument(messages).toJson(QJsonDocument::Compact);
  // JSON numerics and escaped text tokenize more densely than ordinary prose.
  return static_cast<int>((encoded.size() + 1) / 2) + messages.size() * 8;
}

PromptBudgetResult ChatPromptBudget::fitHistory(const QJsonObject &systemMessage,
                                                 const QJsonArray &history,
                                                 int tokenBudget) {
  PromptBudgetResult result;
  result.history = history;
  const int budget = std::max(0, tokenBudget);
  while (estimateTokens(combinedMessages(systemMessage, result.history)) > budget) {
    const int nextTurn = nextUserMessage(result.history);
    if (nextTurn < 0) break;
    for (int i = 0; i < nextTurn; ++i) result.history.removeAt(0);
    ++result.droppedTurns;
  }
  result.estimatedTokens = estimateTokens(combinedMessages(systemMessage, result.history));
  return result;
}

int ChatPromptBudget::providerPromptLimit(const QString &errorText) {
  static const QRegularExpression exceeded(
      QStringLiteral("prompt\\s+tokens\\s+limit\\s+exceeded\\s*:\\s*\\d+\\s*>\\s*(\\d+)"),
      QRegularExpression::CaseInsensitiveOption);
  static const QRegularExpression contextLength(
      QStringLiteral("maximum\\s+context\\s+length\\s+is\\s+(\\d+)\\s+tokens?"),
      QRegularExpression::CaseInsensitiveOption);
  for (const auto &pattern : {exceeded, contextLength}) {
    const auto match = pattern.match(errorText);
    if (match.hasMatch()) {
      bool ok = false;
      const int limit = match.captured(1).toInt(&ok);
      if (ok && limit >= 1024) return limit;
    }
  }
  return 0;
}

int ChatPromptBudget::reducedBudget(int currentBudget, int providerLimit) {
  if (providerLimit < 1024) return std::max(1024, currentBudget);
  const int withMargin = static_cast<int>(providerLimit * 0.70);
  return std::max(1024, std::min(currentBudget - 1000, withMargin));
}

} // namespace chat
