#include "ThemeManager.h"
#include <QGuiApplication>
#include <QPalette>
#include <QSettings>

ThemeManager::ThemeManager(QObject* parent) : QObject(parent) {
    loadSettings();
}

void ThemeManager::loadSettings() {
    QSettings s("Overtune", "Overtune3");
    m_mode = s.value("themeMode", Dark).toInt();
    m_accentColorIndex = s.value("accentColorIndex", 0).toInt();
    m_oledMode = s.value("oledMode", true).toBool(); // OLED black default
    m_plotLineWidth = s.value("plotLineWidth", 2.2).toDouble();
    m_plotResolution = s.value("plotResolution", 1024).toInt();
    m_showCrosshairByDefault = s.value("showCrosshairByDefault", false).toBool();
    m_animationsEnabled = s.value("animationsEnabled", true).toBool();
    m_defaultSampleRate = s.value("defaultSampleRate", 48000).toInt();
    m_defaultExportLang = s.value("defaultExportLang", 0).toInt();

    if (m_mode == System) {
        applySystemTheme();
    } else {
        m_dark = (m_mode == Dark);
    }
}

void ThemeManager::saveSettings() {
    QSettings s("Overtune", "Overtune3");
    s.setValue("themeMode", m_mode);
    s.setValue("accentColorIndex", m_accentColorIndex);
    s.setValue("oledMode", m_oledMode);
    s.setValue("plotLineWidth", m_plotLineWidth);
    s.setValue("plotResolution", m_plotResolution);
    s.setValue("showCrosshairByDefault", m_showCrosshairByDefault);
    s.setValue("animationsEnabled", m_animationsEnabled);
    s.setValue("defaultSampleRate", m_defaultSampleRate);
    s.setValue("defaultExportLang", m_defaultExportLang);
}

void ThemeManager::setThemeMode(int mode) {
    if (m_mode == mode) return;
    m_mode = mode;
    if (m_mode == System) applySystemTheme();
    else m_dark = (m_mode == Dark);
    saveSettings();
    emit themeModeChanged();
}

void ThemeManager::setAccentColorIndex(int index) {
    if (m_accentColorIndex == index) return;
    m_accentColorIndex = qBound(0, index, 1); // Only Blue(0) and Spotify Green(1)
    saveSettings();
    emit themeModeChanged();
}

void ThemeManager::setOledMode(bool enabled) {
    if (m_oledMode == enabled) return;
    m_oledMode = enabled;
    saveSettings();
    emit themeModeChanged();
}

void ThemeManager::setPlotLineWidth(double width) {
    if (qFuzzyCompare(m_plotLineWidth, width)) return;
    m_plotLineWidth = width;
    saveSettings();
    emit plotSettingsChanged();
}

void ThemeManager::setPlotResolution(int resolution) {
    if (m_plotResolution == resolution) return;
    m_plotResolution = resolution;
    saveSettings();
    emit plotSettingsChanged();
}

void ThemeManager::setShowCrosshairByDefault(bool show) {
    if (m_showCrosshairByDefault == show) return;
    m_showCrosshairByDefault = show;
    saveSettings();
    emit plotSettingsChanged();
}

void ThemeManager::setAnimationsEnabled(bool enabled) {
    if (m_animationsEnabled == enabled) return;
    m_animationsEnabled = enabled;
    saveSettings();
    emit uiSettingsChanged();
}

void ThemeManager::setDefaultSampleRate(int rate) {
    if (m_defaultSampleRate == rate) return;
    m_defaultSampleRate = rate;
    saveSettings();
    emit dspSettingsChanged();
}

void ThemeManager::setDefaultExportLang(int lang) {
    if (m_defaultExportLang == lang) return;
    m_defaultExportLang = lang;
    saveSettings();
    emit exportSettingsChanged();
}

void ThemeManager::resetToDefaults() {
    m_mode = Dark;
    m_dark = true;
    m_accentColorIndex = 0;  // Blue
    m_oledMode = true;       // OLED black is the default
    m_plotLineWidth = 2.2;
    m_plotResolution = 1024;
    m_showCrosshairByDefault = false;
    m_animationsEnabled = true;
    m_defaultSampleRate = 48000;
    m_defaultExportLang = 0;
    saveSettings();
    emit themeModeChanged();
    emit plotSettingsChanged();
    emit uiSettingsChanged();
    emit dspSettingsChanged();
    emit exportSettingsChanged();
}

void ThemeManager::applySystemTheme() {
    const QColor windowColor = QGuiApplication::palette().color(QPalette::Window);
    m_dark = windowColor.lightness() < 128;
}

// ── Color Resolvers ─────────────────────────────────────────────────────────

QString ThemeManager::background() const {
    if (m_dark) {
        return m_oledMode ? "#000000" : "#111113";
    }
    return "#F5F5F7";
}

QString ThemeManager::surface() const {
    if (m_dark) {
        return m_oledMode ? "#0C0C0E" : "#1C1C1E";
    }
    return "#FFFFFF";
}

QString ThemeManager::surfaceHigh() const {
    if (m_dark) {
        return m_oledMode ? "#161619" : "#2C2C2E";
    }
    return "#F0F0F5";
}

QString ThemeManager::primaryText() const {
    return m_dark ? "#F5F5F7" : "#1D1D1F";
}

QString ThemeManager::secondaryText() const {
    return m_dark ? "#8E8E93" : "#6E6E73";
}

QString ThemeManager::borderColor() const {
    if (m_dark) {
        return m_oledMode ? "#242428" : "#38383A";
    }
    return "#D1D1D6";
}

QString ThemeManager::accent() const {
    switch (m_accentColorIndex) {
    case 1: return "#1DB954"; // Spotify Green
    case 0:
    default:
        return "#0A84FF";     // Electric Blue (Default)
    }
}

QString ThemeManager::accentMuted() const {
    if (m_dark) {
        switch (m_accentColorIndex) {
        case 1: return "#0D2E17"; // Spotify Green muted
        case 0:
        default:
            return "#1A3A5C"; // Blue muted
        }
    } else {
        switch (m_accentColorIndex) {
        case 1: return "#CCEFDC";
        case 0:
        default:
            return "#D0E4FF";
        }
    }
}

QString ThemeManager::plotGrid() const {
    if (m_dark) {
        return m_oledMode ? "#1B1B1F" : "#2A2A2E";
    }
    return "#E5E5EA";
}

QString ThemeManager::plotCurve() const {
    return accent();
}

QString ThemeManager::sidebarBg() const {
    if (m_dark) {
        return m_oledMode ? "#08080A" : "#161618";
    }
    return "#EBEBED";
}

QString ThemeManager::activityBarBg() const {
    if (m_dark) {
        return m_oledMode ? "#040406" : "#181818";
    }
    return "#F3F3F3";
}

QString ThemeManager::danger() const {
    return "#FF453A";
}

