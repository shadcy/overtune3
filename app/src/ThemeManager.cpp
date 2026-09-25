#include "ThemeManager.h"
#include <QGuiApplication>
#include <QPalette>

ThemeManager::ThemeManager(QObject* parent) : QObject(parent) {
    // Qt 6.4: detect dark mode via palette lightness heuristic
    applySystemTheme();
}

void ThemeManager::setThemeMode(int mode) {
    if (m_mode == mode) return;
    m_mode = mode;
    if (m_mode == System) applySystemTheme();
    else m_dark = (m_mode == Dark);
    emit themeModeChanged();
}

void ThemeManager::applySystemTheme() {
    // Qt 6.4-compatible dark mode detection:
    // compare window background brightness to midpoint
    const QColor windowColor = QGuiApplication::palette().color(QPalette::Window);
    m_dark = windowColor.lightness() < 128;
}

// ── Dark palette ──────────────────────────────────────────────────────────────
// ── Light palette ─────────────────────────────────────────────────────────────

QString ThemeManager::background()    const { return m_dark ? "#111113" : "#F5F5F7"; }
QString ThemeManager::surface()       const { return m_dark ? "#1C1C1E" : "#FFFFFF"; }
QString ThemeManager::surfaceHigh()   const { return m_dark ? "#2C2C2E" : "#F0F0F5"; }
QString ThemeManager::primaryText()   const { return m_dark ? "#F5F5F7" : "#1D1D1F"; }
QString ThemeManager::secondaryText() const { return m_dark ? "#8E8E93" : "#6E6E73"; }
QString ThemeManager::borderColor()   const { return m_dark ? "#38383A" : "#D1D1D6"; }
QString ThemeManager::accent()        const { return "#0A84FF"; }
QString ThemeManager::accentMuted()   const { return m_dark ? "#1A3A5C" : "#D0E4FF"; }
QString ThemeManager::plotGrid()      const { return m_dark ? "#2A2A2E" : "#E5E5EA"; }
QString ThemeManager::plotCurve()     const { return "#0A84FF"; }
QString ThemeManager::sidebarBg()     const { return m_dark ? "#161618" : "#EBEBED"; }
QString ThemeManager::activityBarBg() const { return m_dark ? "#181818" : "#F3F3F3"; }
QString ThemeManager::danger()        const { return "#FF453A"; }
