#include "ChatPromptBudget.h"

#include <QJsonObject>

#include <cstdlib>
#include <iostream>

namespace {
int failures = 0;

void check(bool condition, const char *message) {
  if (!condition) {
    std::cerr << "FAIL: " << message << '\n';
    ++failures;
  }
}

QJsonObject textMessage(const QString &role, const QString &text) {
  return {{QStringLiteral("role"), role}, {QStringLiteral("content"), text}};
}

void runTurnPruningCases() {
  const QJsonObject system = textMessage(QStringLiteral("system"),
      QStringLiteral("Concise DSP assistant instructions and current design."));
  QJsonArray history{
      textMessage(QStringLiteral("user"), QString(1800, QLatin1Char('a'))),
      textMessage(QStringLiteral("assistant"), QString(1800, QLatin1Char('b'))),
      textMessage(QStringLiteral("user"), QStringLiteral("Compare the variants.")),
      QJsonObject{{QStringLiteral("role"), QStringLiteral("assistant")},
                  {QStringLiteral("tool_calls"), QJsonArray{QJsonObject{{QStringLiteral("id"), QStringLiteral("call-1")}}}}},
      QJsonObject{{QStringLiteral("role"), QStringLiteral("tool")},
                  {QStringLiteral("tool_call_id"), QStringLiteral("call-1")},
                  {QStringLiteral("content"), QString(1800, QLatin1Char('c'))}},
      textMessage(QStringLiteral("assistant"), QStringLiteral("Comparison complete.")),
      textMessage(QStringLiteral("user"), QStringLiteral("Explain the latest plot."))};

  const int latestOnlyBudget = chat::ChatPromptBudget::estimateTokens(
      QJsonArray{system, history.last()}) + 4;
  const auto fit = chat::ChatPromptBudget::fitHistory(system, history, latestOnlyBudget);
  check(fit.droppedTurns == 2, "drops oldest complete turns until the prompt fits");
  check(fit.history.size() == 1 &&
        fit.history.first().toObject().value(QStringLiteral("content")).toString() ==
            QStringLiteral("Explain the latest plot."),
        "preserves the latest user prompt");
  check(fit.estimatedTokens <= latestOnlyBudget, "returns a prompt within its token budget");

  QJsonArray recentToolTurn{
      textMessage(QStringLiteral("user"), QStringLiteral("Compare these designs.")),
      QJsonObject{{QStringLiteral("role"), QStringLiteral("assistant")},
                  {QStringLiteral("tool_calls"), QJsonArray{QJsonObject{{QStringLiteral("id"), QStringLiteral("call-2")}}}}},
      QJsonObject{{QStringLiteral("role"), QStringLiteral("tool")},
                  {QStringLiteral("tool_call_id"), QStringLiteral("call-2")},
                  {QStringLiteral("content"), QStringLiteral("Computed comparison data.")}},
      textMessage(QStringLiteral("assistant"), QStringLiteral("Here is the comparison."))};
  QJsonArray withOldTurn{
      textMessage(QStringLiteral("user"), QString(1800, QLatin1Char('x'))),
      textMessage(QStringLiteral("assistant"), QString(1800, QLatin1Char('y')))};
  for (const auto &message : recentToolTurn) withOldTurn.append(message);
  const int recentTurnBudget = chat::ChatPromptBudget::estimateTokens(
      QJsonArray{system, recentToolTurn.first(), recentToolTurn.at(1),
                 recentToolTurn.at(2), recentToolTurn.last()}) + 4;
  const auto recentFit = chat::ChatPromptBudget::fitHistory(system, withOldTurn, recentTurnBudget);
  check(recentFit.droppedTurns == 1 && recentFit.history.size() == 4,
        "preserves the newest complete tool exchange while pruning older turns");
  check(recentFit.history.at(1).toObject().value(QStringLiteral("tool_calls")).isArray() &&
        recentFit.history.at(2).toObject().value(QStringLiteral("tool_call_id")).toString() ==
            QStringLiteral("call-2"),
        "keeps tool call and result messages paired");
}

void runProviderLimitCases() {
  check(chat::ChatPromptBudget::providerPromptLimit(
            QStringLiteral("prompt tokens limit exceeded: 15005 > 13581")) == 13581,
        "reads the actual provider prompt ceiling");
  check(chat::ChatPromptBudget::providerPromptLimit(
            QStringLiteral("maximum context length is 8192 tokens")) == 8192,
        "reads the standard context length error");
  check(chat::ChatPromptBudget::providerPromptLimit(QStringLiteral("rate limited")) == 0,
        "leaves unrelated provider errors unclassified");
  check(chat::ChatPromptBudget::reducedBudget(10000, 13581) == 9000,
        "reduces the request ceiling with room for estimation variance");
  check(chat::ChatPromptBudget::reducedBudget(4000, 3000) == 2100,
        "adapts to a provider's smaller reported prompt ceiling");
}

void runOversizedLatestTurnCase() {
  const QJsonObject system = textMessage(QStringLiteral("system"), QStringLiteral("Rules"));
  const QJsonArray history{textMessage(QStringLiteral("user"), QString(4000, QLatin1Char('x')))};
  const auto fit = chat::ChatPromptBudget::fitHistory(system, history, 100);
  check(fit.history.size() == 1, "never silently drops the only user request");
  check(fit.estimatedTokens > 100, "reports when the newest request itself cannot fit");
}
}

int main() {
  runTurnPruningCases();
  runProviderLimitCases();
  runOversizedLatestTurnCase();
  if (failures) return EXIT_FAILURE;
  std::cout << "Chat prompt budget harness passed.\n";
  return EXIT_SUCCESS;
}
