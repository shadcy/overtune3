#include "ExportModel.h"
#include "FilterEngine.h"
#include <QFile>
#include <QGuiApplication>
#include <QClipboard>

ExportModel::ExportModel(QObject* parent) : QObject(parent) {}

void ExportModel::generate(QObject* enginePtr) {
    auto* eng = qobject_cast<FilterEngine*>(enginePtr);
    if (!eng) return;
    m_code = eng->exportCode(m_format);
    emit codeChanged();
}

bool ExportModel::saveToFile(const QString& path) {
    QFile f(path);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) return false;
    f.write(m_code.toUtf8());
    return true;
}

void ExportModel::copyToClipboard() {
    QGuiApplication::clipboard()->setText(m_code);
}
