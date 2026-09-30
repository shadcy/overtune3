#pragma once
#include <QObject>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QProcess>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QCoreApplication>
#include <QCryptographicHash>

class UpdateInstallerEngine : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString currentVersion READ currentVersion CONSTANT)
    Q_PROPERTY(QString latestVersion READ latestVersion NOTIFY updateInfoChanged)
    Q_PROPERTY(QString releaseName READ releaseName NOTIFY updateInfoChanged)
    Q_PROPERTY(QString releaseDate READ releaseDate NOTIFY updateInfoChanged)
    Q_PROPERTY(QStringList releaseNotes READ releaseNotes NOTIFY updateInfoChanged)
    Q_PROPERTY(QString releaseSize READ releaseSize NOTIFY updateInfoChanged)
    Q_PROPERTY(QString releaseSha256 READ releaseSha256 NOTIFY updateInfoChanged)

    Q_PROPERTY(bool hasUpdate READ hasUpdate NOTIFY updateInfoChanged)
    Q_PROPERTY(bool isChecking READ isChecking NOTIFY stateChanged)
    Q_PROPERTY(bool isDownloading READ isDownloading NOTIFY stateChanged)
    Q_PROPERTY(bool isInstalling READ isInstalling NOTIFY stateChanged)
    Q_PROPERTY(bool isReadyToRestart READ isReadyToRestart NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY stateChanged)
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString downloadSpeed READ downloadSpeed NOTIFY progressChanged)

    Q_PROPERTY(QString osName READ osName CONSTANT)
    Q_PROPERTY(QString installPath READ installPath WRITE setInstallPath NOTIFY installPathChanged)
    Q_PROPERTY(QString defaultInstallPath READ defaultInstallPath CONSTANT)
    Q_PROPERTY(bool isInstalled READ isInstalled NOTIFY stateChanged)
    Q_PROPERTY(bool createDesktopShortcut READ createDesktopShortcut WRITE setCreateDesktopShortcut NOTIFY shortcutPrefsChanged)
    Q_PROPERTY(bool createStartMenu READ createStartMenu WRITE setCreateStartMenu NOTIFY shortcutPrefsChanged)
    Q_PROPERTY(QString updateChannel READ updateChannel WRITE setUpdateChannel NOTIFY updateChannelChanged)

public:
    explicit UpdateInstallerEngine(QObject *parent = nullptr);
    ~UpdateInstallerEngine() override = default;

    QString currentVersion() const { return QStringLiteral("3.0.0"); }
    QString latestVersion() const { return m_latestVersion; }
    QString releaseName() const { return m_releaseName; }
    QString releaseDate() const { return m_releaseDate; }
    QStringList releaseNotes() const { return m_releaseNotes; }
    QString releaseSize() const { return m_releaseSize; }
    QString releaseSha256() const { return m_releaseSha256; }

    bool hasUpdate() const { return m_hasUpdate; }
    bool isChecking() const { return m_status == QStringLiteral("checking"); }
    bool isDownloading() const { return m_status == QStringLiteral("downloading"); }
    bool isInstalling() const { return m_status == QStringLiteral("applying") || m_status == QStringLiteral("installing"); }
    bool isReadyToRestart() const { return m_status == QStringLiteral("ready_to_restart"); }
    QString status() const { return m_status; }
    QString statusMessage() const { return m_statusMessage; }
    qreal progress() const { return m_progress; }
    QString downloadSpeed() const { return m_downloadSpeed; }

    QString osName() const;
    QString installPath() const { return m_installPath; }
    void setInstallPath(const QString &path);
    QString defaultInstallPath() const;
    bool isInstalled() const;

    bool createDesktopShortcut() const { return m_createDesktopShortcut; }
    void setCreateDesktopShortcut(bool val);
    bool createStartMenu() const { return m_createStartMenu; }
    void setCreateStartMenu(bool val);

    QString updateChannel() const { return m_updateChannel; }
    void setUpdateChannel(const QString &channel);

    Q_INVOKABLE void checkForUpdates(bool forceUpdateFound = false);
    Q_INVOKABLE void startDownloadAndInstall();
    Q_INVOKABLE void installToSystem(const QString &targetPath = QString(), bool desktopIcon = true, bool startMenu = true);
    Q_INVOKABLE void restartApplication();
    Q_INVOKABLE void createShortcuts();
    Q_INVOKABLE void openInstallDirectory();
    Q_INVOKABLE void resetStatus();

signals:
    void updateInfoChanged();
    void stateChanged();
    void progressChanged();
    void installPathChanged();
    void shortcutPrefsChanged();
    void updateChannelChanged();
    void updateError(const QString &message);
    void updateSuccess(const QString &message);

private slots:
    void onCheckTimerTick();
    void onDownloadTimerTick();
    void onApplyTimerTick();

private:
    void setStatus(const QString &newStatus, const QString &message);
    void setProgress(qreal p);
    bool performLinuxInstall(const QString &dir, bool desktop, bool menu);
    bool performWindowsInstall(const QString &dir, bool desktop, bool menu);

    QString m_latestVersion = QStringLiteral("3.1.0");
    QString m_releaseName = QStringLiteral("Overtune 3.1.0 — High-Precision DSP & Adaptive Audio");
    QString m_releaseDate = QStringLiteral("October 2026");
    QStringList m_releaseNotes;
    QString m_releaseSize = QStringLiteral("24.8 MB");
    QString m_releaseSha256 = QStringLiteral("e9a8f273b4018c6d123e4f0a91e523bd8a230491823746acdb0192837465fec1");

    bool m_hasUpdate = false;
    QString m_status = QStringLiteral("idle");
    QString m_statusMessage = QStringLiteral("Ready");
    qreal m_progress = 0.0;
    QString m_downloadSpeed = QStringLiteral("0 MB/s");

    QString m_installPath;
    bool m_createDesktopShortcut = true;
    bool m_createStartMenu = true;
    QString m_updateChannel = QStringLiteral("stable");

    QTimer *m_checkTimer = nullptr;
    QTimer *m_downloadTimer = nullptr;
    QTimer *m_applyTimer = nullptr;
    int m_simStep = 0;
};
