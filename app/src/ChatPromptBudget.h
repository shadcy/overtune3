#pragma once

#include <QJsonArray>
#include <QJsonObject>
#include <QString>

namespace chat {

struct PromptBudgetResult {
  QJsonArray history;
  int estimatedTokens{0};
  int droppedTurns{0};
};

class ChatPromptBudget {
public:
  static int estimateTokens(const QJsonArray &messages);
  static PromptBudgetResult fitHistory(const QJsonObject &systemMessage,
                                      const QJsonArray &history,
                                      int tokenBudget);
  static int providerPromptLimit(const QString &errorText);
  static int reducedBudget(int currentBudget, int providerLimit);
};

} // namespace chat
