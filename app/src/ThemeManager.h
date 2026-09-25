#pragma once
#include <QObject>
#include <QString>

class ThemeManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(int     themeMode READ themeMode WRITE setThemeMode NOTIFY themeModeChanged)
    Q_PROPERTY(bool    isDark    READ isDark    NOTIFY themeModeChanged)
    // Resolved colors
    Q_PROPERTY(QString background    READ background    NOTIFY themeModeChanged)
    Q_PROPERTY(QString surface       READ surface       NOTIFY themeModeChanged)
    Q_PROPERTY(QString surfaceHigh   READ surfaceHigh   NOTIFY themeModeChanged)
    Q_PROPERTY(QString primaryText   READ primaryText   NOTIFY themeModeChanged)
    Q_PROPERTY(QString secondaryText READ secondaryText NOTIFY themeModeChanged)
    Q_PROPERTY(QString borderColor   READ borderColor   NOTIFY themeModeChanged)
    Q_PROPERTY(QString accent        READ accent        NOTIFY themeModeChanged)
    Q_PROPERTY(QString accentMuted   READ accentMuted   NOTIFY themeModeChanged)
    Q_PROPERTY(QString plotGrid      READ plotGrid      NOTIFY themeModeChanged)
    Q_PROPERTY(QString plotCurve     READ plotCurve     NOTIFY themeModeChanged)
    Q_PROPERTY(QString sidebarBg     READ sidebarBg     NOTIFY themeModeChanged)
    Q_PROPERTY(QString activityBarBg READ activityBarBg NOTIFY themeModeChanged)
    Q_PROPERTY(QString danger        READ danger        NOTIFY themeModeChanged)

public:
    enum ThemeMode { System = 0, Light = 1, Dark = 2 };
    Q_ENUM(ThemeMode)

    explicit ThemeManager(QObject* parent = nullptr);

    int  themeMode() const { return m_mode; }
    bool isDark()    const { return m_dark; }

    void setThemeMode(int mode);

    QString background()    const;
    QString surface()       const;
    QString surfaceHigh()   const;
    QString primaryText()   const;
    QString secondaryText() const;
    QString borderColor()   const;
    QString accent()        const;
    QString accentMuted()   const;
    QString plotGrid()      const;
    QString plotCurve()     const;
    QString sidebarBg()     const;
    QString activityBarBg() const;
    QString danger()        const;

signals:
    void themeModeChanged();

private:
    void applySystemTheme();
    int  m_mode{System};
    bool m_dark{true};
};
