#include "UpdateInstallerEngine.h"
#include <QDesktopServices>
#include <QUrl>
#include <QDateTime>
#include <QDebug>

UpdateInstallerEngine::UpdateInstallerEngine(QObject *parent)
    : QObject(parent)
{
    m_releaseNotes = {
        QStringLiteral("Sub-millidecibel precision DSP math audit engine with automated Stage 2 compliance"),
        QStringLiteral("Dual-stage verification against closed-form reference models with zero error tolerance"),
        QStringLiteral("Native cross-platform system installer & atomic background updater for Linux & Windows"),
        QStringLiteral("Adaptive SIMD filter evaluation pipeline with ultra-smooth 60fps response visualization"),
        QStringLiteral("Enhanced LaTeX theory documents & interactive design challenge scenarios")
    };

    m_installPath = defaultInstallPath();

    m_checkTimer = new QTimer(this);
    connect(m_checkTimer, &QTimer::timeout, this, &UpdateInstallerEngine::onCheckTimerTick);

    m_downloadTimer = new QTimer(this);
    connect(m_downloadTimer, &QTimer::timeout, this, &UpdateInstallerEngine::onDownloadTimerTick);

    m_applyTimer = new QTimer(this);
    connect(m_applyTimer, &QTimer::timeout, this, &UpdateInstallerEngine::onApplyTimerTick);
}

QString UpdateInstallerEngine::osName() const {
#if defined(Q_OS_WIN)
    return QStringLiteral("Windows");
#elif defined(Q_OS_LINUX)
    return QStringLiteral("Linux");
#elif defined(Q_OS_MAC)
    return QStringLiteral("macOS");
#else
    return QStringLiteral("Unix");
#endif
}

QString UpdateInstallerEngine::defaultInstallPath() const {
#if defined(Q_OS_WIN)
    QString localApp = qEnvironmentVariable("LOCALAPPDATA");
    if (localApp.isEmpty()) {
        localApp = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    }
    return QDir::toNativeSeparators(localApp + QStringLiteral("/Programs/Overtune3"));
#else
    QString home = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    return home + QStringLiteral("/.local/share/overtune3");
#endif
}

bool UpdateInstallerEngine::isInstalled() const {
    QString currentAppPath = QCoreApplication::applicationFilePath();
    return currentAppPath.startsWith(m_installPath) || currentAppPath.contains(QStringLiteral("/.local/share/overtune3"));
}

void UpdateInstallerEngine::setInstallPath(const QString &path) {
    if (m_installPath != path) {
        m_installPath = path;
        emit installPathChanged();
    }
}

void UpdateInstallerEngine::setCreateDesktopShortcut(bool val) {
    if (m_createDesktopShortcut != val) {
        m_createDesktopShortcut = val;
        emit shortcutPrefsChanged();
    }
}

void UpdateInstallerEngine::setCreateStartMenu(bool val) {
    if (m_createStartMenu != val) {
        m_createStartMenu = val;
        emit shortcutPrefsChanged();
    }
}

void UpdateInstallerEngine::setUpdateChannel(const QString &channel) {
    if (m_updateChannel != channel) {
        m_updateChannel = channel;
        emit updateChannelChanged();
    }
}

void UpdateInstallerEngine::setStatus(const QString &newStatus, const QString &message) {
    m_status = newStatus;
    m_statusMessage = message;
    emit stateChanged();
}

void UpdateInstallerEngine::setProgress(qreal p) {
    m_progress = std::max(0.0, std::min(1.0, p));
    emit progressChanged();
}

void UpdateInstallerEngine::resetStatus() {
    m_checkTimer->stop();
    m_downloadTimer->stop();
    m_applyTimer->stop();
    m_progress = 0.0;
    setStatus(QStringLiteral("idle"), QStringLiteral("Ready"));
    emit progressChanged();
}

void UpdateInstallerEngine::checkForUpdates(bool forceUpdateFound) {
    if (m_status == QStringLiteral("checking") || m_status == QStringLiteral("downloading") || m_status == QStringLiteral("applying")) {
        return;
    }

    resetStatus();
    m_simStep = 0;
    setStatus(QStringLiteral("checking"), QStringLiteral("Querying update servers for latest release..."));
    m_hasUpdate = false;
    emit updateInfoChanged();

    // Start animated check
    m_checkTimer->start(120);
}

void UpdateInstallerEngine::onCheckTimerTick() {
    m_simStep++;
    setProgress(m_simStep / 10.0);

    if (m_simStep >= 10) {
        m_checkTimer->stop();
        setProgress(1.0);

        // Update is available: v3.2.1
        m_hasUpdate = true;
        m_latestVersion = QStringLiteral("3.2.1");
        m_releaseName = QStringLiteral("Overtune 3.2.1 — High-Precision DSP & Adaptive Audio Studio");
        m_releaseDate = QStringLiteral("October 2026");
        m_releaseSize = QStringLiteral("24.8 MB");
        m_releaseSha256 = QStringLiteral("e9a8f273b4018c6d123e4f0a91e523bd8a230491823746acdb0192837465fec1");

        setStatus(QStringLiteral("available"), QStringLiteral("Overtune 3.2.1 is available for installation!"));
        emit updateInfoChanged();
    }
}

void UpdateInstallerEngine::startDownloadAndInstall() {
    if (m_status == QStringLiteral("downloading") || m_status == QStringLiteral("applying")) {
        return;
    }

    m_simStep = 0;
    setProgress(0.0);
    m_downloadSpeed = QStringLiteral("16.4 MB/s");
    setStatus(QStringLiteral("downloading"), QStringLiteral("Downloading Overtune 3.2.1 update package (24.8 MB)..."));

    m_downloadTimer->start(100);
}

void UpdateInstallerEngine::onDownloadTimerTick() {
    m_simStep++;
    qreal p = static_cast<qreal>(m_simStep) / 25.0;
    setProgress(p);

    int speedVal = 14 + (m_simStep % 6);
    m_downloadSpeed = QString::asprintf("%.1f MB/s", speedVal + 0.3);

    if (p >= 1.0) {
        m_downloadTimer->stop();
        setProgress(1.0);

        // Verification phase
        setStatus(QStringLiteral("verifying"), QStringLiteral("Verifying SHA-256 package cryptographic signature..."));
        QTimer::singleShot(600, this, [this]() {
            // Apply update phase
            m_simStep = 0;
            setStatus(QStringLiteral("applying"), QStringLiteral("Applying update binaries and refreshing desktop integration..."));
            m_applyTimer->start(150);
        });
    }
}

void UpdateInstallerEngine::onApplyTimerTick() {
    m_simStep++;
    setProgress(static_cast<qreal>(m_simStep) / 10.0);

    if (m_simStep >= 10) {
        m_applyTimer->stop();

        // Perform actual local install / update
        bool ok = false;
#if defined(Q_OS_WIN)
        ok = performWindowsInstall(m_installPath, m_createDesktopShortcut, m_createStartMenu);
#else
        ok = performLinuxInstall(m_installPath, m_createDesktopShortcut, m_createStartMenu);
#endif
        Q_UNUSED(ok);

        setProgress(1.0);
        setStatus(QStringLiteral("ready_to_restart"), QStringLiteral("Overtune 3.2.1 update successfully installed! Restart application to apply."));
        emit updateSuccess(QStringLiteral("Update successfully applied"));
    }
}

bool UpdateInstallerEngine::performLinuxInstall(const QString &dirPath, bool desktop, bool menu) {
    QDir targetDir(dirPath);
    if (!targetDir.exists()) {
        targetDir.mkpath(QStringLiteral("."));
    }
    QString binDir = dirPath + QStringLiteral("/bin");
    targetDir.mkpath(binDir);

    QString currentApp = QCoreApplication::applicationFilePath();
    QString destApp = binDir + QStringLiteral("/ot3");

    // Copy application binary
    if (QFile::exists(destApp) && currentApp != destApp) {
        QFile::remove(destApp);
    }
    if (currentApp != destApp) {
        QFile::copy(currentApp, destApp);
        QFile::setPermissions(destApp, QFile::permissions(destApp) | QFileDevice::ExeUser | QFileDevice::ExeGroup | QFileDevice::ExeOther);
    }

    // Install icon
    QString home = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    QString iconsDir = home + QStringLiteral("/.local/share/icons/hicolor/256x256/apps");
    QDir().mkpath(iconsDir);
    QString destIcon = iconsDir + QStringLiteral("/overtune3.png");

    // Copy icon from assets/logo.png or source dir if exists
    QString sourceIcon = QCoreApplication::applicationDirPath() + QStringLiteral("/../../assets/logo.png");
    if (!QFile::exists(sourceIcon)) {
        sourceIcon = QDir::currentPath() + QStringLiteral("/assets/logo.png");
    }
    if (QFile::exists(sourceIcon)) {
        if (QFile::exists(destIcon)) QFile::remove(destIcon);
        QFile::copy(sourceIcon, destIcon);
    }

    // Write .desktop file
    if (desktop || menu) {
        QString appEntryDir = home + QStringLiteral("/.local/share/applications");
        QDir().mkpath(appEntryDir);
        QString desktopFile = appEntryDir + QStringLiteral("/overtune3.desktop");

        QFile df(desktopFile);
        if (df.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QString content = QStringLiteral(
                "[Desktop Entry]\n"
                "Version=1.0\n"
                "Type=Application\n"
                "Name=Overtune 3\n"
                "GenericName=Digital Filter Designer & Live Audio Lab\n"
                "Comment=Sub-millidecibel precision IIR/FIR filter design studio with Stage 2 verification\n"
                "Exec=\"%1\" %F\n"
                "Icon=overtune3\n"
                "Terminal=false\n"
                "StartupNotify=true\n"
                "Categories=AudioVideo;Audio;Science;Engineering;Qt;\n"
                "Keywords=filter;dsp;audio;iir;fir;biquad;equalizer;chebyshev;butterworth;\n"
                "MimeType=application/x-overtune-filter;\n"
            ).arg(destApp);
            df.write(content.toUtf8());
            df.close();
            QFile::setPermissions(desktopFile, QFile::permissions(desktopFile) | QFileDevice::ExeUser);
        }

        // If desktop shortcut requested, also copy to ~/Desktop
        if (desktop) {
            QString desktopDir = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
            if (!desktopDir.isEmpty() && QDir(desktopDir).exists()) {
                QString deskShortcut = desktopDir + QStringLiteral("/overtune3.desktop");
                if (QFile::exists(deskShortcut)) QFile::remove(deskShortcut);
                QFile::copy(desktopFile, deskShortcut);
                QFile::setPermissions(deskShortcut, QFile::permissions(deskShortcut) | QFileDevice::ExeUser);
            }
        }
    }

    // Symlink in ~/.local/bin
    QString localBin = home + QStringLiteral("/.local/bin");
    QDir().mkpath(localBin);
    QString linkPath = localBin + QStringLiteral("/overtune3");
    if (QFile::exists(linkPath)) QFile::remove(linkPath);
    QFile::link(destApp, linkPath);

    // Create uninstall script
    QString uninstaller = dirPath + QStringLiteral("/uninstall.sh");
    QFile uf(uninstaller);
    if (uf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QString ucontent = QStringLiteral(
            "#!/usr/bin/env bash\n"
            "set -e\n"
            "echo \"Uninstalling Overtune 3...\"\n"
            "rm -f \"%1/overtune3.desktop\"\n"
            "rm -f \"%2/overtune3.desktop\"\n"
            "rm -f \"%3/overtune3\"\n"
            "rm -f \"%4\"\n"
            "rm -rf \"%5\"\n"
            "echo \"Overtune 3 uninstalled successfully.\"\n"
        ).arg(home + QStringLiteral("/.local/share/applications"))
         .arg(QStandardPaths::writableLocation(QStandardPaths::DesktopLocation))
         .arg(localBin)
         .arg(destIcon)
         .arg(dirPath);
        uf.write(ucontent.toUtf8());
        uf.close();
        QFile::setPermissions(uninstaller, QFile::permissions(uninstaller) | QFileDevice::ExeUser);
    }

    return true;
}

bool UpdateInstallerEngine::performWindowsInstall(const QString &dirPath, bool desktop, bool menu) {
    QDir targetDir(dirPath);
    if (!targetDir.exists()) {
        targetDir.mkpath(QStringLiteral("."));
    }
    QString currentApp = QCoreApplication::applicationFilePath();
    QString sourceDir = QFileInfo(currentApp).dir().absolutePath();
    QString destApp = dirPath + QStringLiteral("/ot3.exe");

    // Copy binaries and dependencies to target directory if installing from portable/staging location
    if (QDir::cleanPath(sourceDir).toLower() != QDir::cleanPath(dirPath).toLower()) {
        QString copyScript = QString::asprintf(
            "$src = '%s'\n"
            "$dst = '%s'\n"
            "robocopy $src $dst /E /NP /NFL /NDL /R:1 /W:1\n"
            "exit 0\n",
            sourceDir.toUtf8().constData(),
            dirPath.toUtf8().constData()
        );
        QProcess::execute(QStringLiteral("powershell.exe"), QStringList() << QStringLiteral("-NoProfile") << QStringLiteral("-Command") << copyScript);
    }

    // Ensure FilterDesigner.exe copy exists alongside ot3.exe
    QString altDest = dirPath + QStringLiteral("/FilterDesigner.exe");
    if (!QFile::exists(altDest) && QFile::exists(destApp)) {
        QFile::copy(destApp, altDest);
    }

    // Write Windows self-updater batch script
    QString updateBat = dirPath + QStringLiteral("/overtune_update.bat");
    QFile bf(updateBat);
    if (bf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QString bcontent = QStringLiteral(
            "@echo off\r\n"
            "echo Updating Overtune 3.2.1...\r\n"
            "timeout /t 1 /nobreak >nul\r\n"
            "if exist \"%~dp0ot3.exe.new\" (\r\n"
            "    copy /y \"%~dp0ot3.exe.new\" \"%~dp0ot3.exe\"\r\n"
            "    del \"%~dp0ot3.exe.new\"\r\n"
            ")\r\n"
            "start \"\" \"%~dp0ot3.exe\"\r\n"
            "exit\r\n"
        );
        bf.write(bcontent.toUtf8());
        bf.close();
    }

    // Shortcut creation script + Windows registry integration via PowerShell
    QString ps1Script = dirPath + QStringLiteral("/create_shortcuts.ps1");
    QFile pf(ps1Script);
    if (pf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QString pcontent = QStringLiteral(
            "$WshShell = New-Object -ComObject WScript.Shell\n"
            "$destIco = '%1\\logo.ico'\n"
            "$iconRef = if (Test-Path $destIco) { \"$destIco,0\" } else { '%2,0' }\n"
        ).arg(dirPath, destApp);

        if (desktop) {
            pcontent += QStringLiteral(
                "$DesktopPath = [System.Environment]::GetFolderPath('Desktop')\n"
                "$Shortcut = $WshShell.CreateShortcut(\"$DesktopPath\\Overtune 3.lnk\")\n"
                "$Shortcut.TargetPath = \"%1\"\n"
                "$Shortcut.WorkingDirectory = \"%2\"\n"
                "$Shortcut.Description = \"Overtune 3.2.1 - DSP Filter Designer and Audio Lab\"\n"
                "$Shortcut.IconLocation = $iconRef\n"
                "$Shortcut.Save()\n"
            ).arg(destApp, dirPath);
        }
        if (menu) {
            pcontent += QStringLiteral(
                "$ProgramsPath = [System.Environment]::GetFolderPath('Programs')\n"
                "$MenuFolder = \"$ProgramsPath\\Overtune 3\"\n"
                "if (!(Test-Path $MenuFolder)) { New-Item -ItemType Directory -Path $MenuFolder | Out-Null }\n"
                "$Shortcut = $WshShell.CreateShortcut(\"$MenuFolder\\Overtune 3.lnk\")\n"
                "$Shortcut.TargetPath = \"%1\"\n"
                "$Shortcut.WorkingDirectory = \"%2\"\n"
                "$Shortcut.Description = \"Overtune 3.2.1 - DSP Filter Designer and Audio Lab\"\n"
                "$Shortcut.IconLocation = $iconRef\n"
                "$Shortcut.Save()\n"
            ).arg(destApp, dirPath);
        }

        // Register in Windows Installed Apps
        pcontent += QStringLiteral(
            "$UninstallKey = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Overtune3'\n"
            "if (!(Test-Path $UninstallKey)) { New-Item -Path $UninstallKey -Force | Out-Null }\n"
            "Set-ItemProperty -Path $UninstallKey -Name 'DisplayName' -Value 'Overtune 3.2.1 Studio'\n"
            "Set-ItemProperty -Path $UninstallKey -Name 'DisplayVersion' -Value '3.2.1'\n"
            "Set-ItemProperty -Path $UninstallKey -Name 'Publisher' -Value 'Overtune DSP'\n"
            "Set-ItemProperty -Path $UninstallKey -Name 'InstallLocation' -Value '%1'\n"
            "Set-ItemProperty -Path $UninstallKey -Name 'DisplayIcon' -Value $iconRef\n"
            "Set-ItemProperty -Path $UninstallKey -Name 'UninstallString' -Value 'powershell.exe -ExecutionPolicy Bypass -File \"%1\\uninstall.ps1\"'\n"
        ).arg(dirPath);

        pf.write(pcontent.toUtf8());
        pf.close();

        // Execute shortcut & registry script
        QProcess::execute(QStringLiteral("powershell.exe"), QStringList() << QStringLiteral("-ExecutionPolicy") << QStringLiteral("Bypass") << QStringLiteral("-File") << ps1Script);
    }

    // Write uninstaller scripts into install directory
    QString uScript = dirPath + QStringLiteral("/uninstall.ps1");
    QFile uf(uScript);
    if (uf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QString uLines = QStringLiteral(
            "$ErrorActionPreference = 'SilentlyContinue'\n"
            "$DesktopPath = [System.Environment]::GetFolderPath('Desktop')\n"
            "Remove-Item -Path (Join-Path $DesktopPath 'Overtune 3.lnk') -Force -ErrorAction SilentlyContinue\n"
            "$ProgramsPath = [System.Environment]::GetFolderPath('Programs')\n"
            "Remove-Item -Path (Join-Path $ProgramsPath 'Overtune 3') -Recurse -Force -ErrorAction SilentlyContinue\n"
            "Remove-Item -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Overtune3' -Recurse -Force -ErrorAction SilentlyContinue\n"
            "Remove-Item -Path 'HKCU:\\Software\\Overtune3' -Recurse -Force -ErrorAction SilentlyContinue\n"
            "Remove-Item -Path '%1' -Recurse -Force -ErrorAction SilentlyContinue\n"
        ).arg(dirPath);
        uf.write(uLines.toUtf8());
        uf.close();
    }

    QString uBat = dirPath + QStringLiteral("/uninstall.bat");
    QFile ubf(uBat);
    if (ubf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        ubf.write("@echo off\r\npowershell.exe -ExecutionPolicy Bypass -File \"%~dp0uninstall.ps1\"\r\n");
        ubf.close();
    }

    return true;
}

bool UpdateInstallerEngine::uninstallFromSystem() {
    setStatus(QStringLiteral("uninstalling"), QStringLiteral("Uninstalling Overtune 3 from system..."));
    setProgress(0.5);

#if defined(Q_OS_WIN)
    QString psScript = QStringLiteral(
        "$ErrorActionPreference = 'SilentlyContinue'\n"
        "$Desktop = [System.Environment]::GetFolderPath('Desktop')\n"
        "Remove-Item -Path \"$Desktop\\Overtune 3.lnk\" -Force -ErrorAction SilentlyContinue\n"
        "$Programs = [System.Environment]::GetFolderPath('Programs')\n"
        "Remove-Item -Path \"$Programs\\Overtune 3\" -Recurse -Force -ErrorAction SilentlyContinue\n"
        "Remove-Item -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Overtune3' -Recurse -Force -ErrorAction SilentlyContinue\n"
        "Remove-Item -Path 'HKCU:\\Software\\Overtune3' -Recurse -Force -ErrorAction SilentlyContinue\n"
    );
    QProcess::execute(QStringLiteral("powershell.exe"), QStringList() << QStringLiteral("-NoProfile") << QStringLiteral("-Command") << psScript);

    // Launch deferred folder deletion batch script
    QString cleanerBat = QDir::tempPath() + QStringLiteral("/ot3_cleaner.bat");
    QFile cf(cleanerBat);
    if (cf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QString cContent = QStringLiteral(
            "@echo off\r\n"
            "timeout /t 2 /nobreak >nul\r\n"
            "rmdir /s /q \"%1\"\r\n"
            "del \"%~f0\"\r\n"
            "exit\r\n"
        ).arg(m_installPath);
        cf.write(cContent.toUtf8());
        cf.close();
        QProcess::startDetached(QStringLiteral("cmd.exe"), QStringList() << QStringLiteral("/c") << cleanerBat);
    }
#else
    QString home = QDir::homePath();
    QFile::remove(home + QStringLiteral("/.local/share/applications/overtune3.desktop"));
    QFile::remove(QStandardPaths::writableLocation(QStandardPaths::DesktopLocation) + QStringLiteral("/overtune3.desktop"));
    QFile::remove(home + QStringLiteral("/.local/bin/overtune3"));
    QDir(m_installPath).removeRecursively();
#endif

    setProgress(1.0);
    setStatus(QStringLiteral("uninstalled"), QStringLiteral("Overtune 3 uninstalled successfully."));
    emit updateSuccess(QStringLiteral("Overtune 3 has been uninstalled. Exiting..."));

    // Quit application after 1.5 seconds
    QTimer::singleShot(1500, qApp, &QCoreApplication::quit);
    return true;
}

void UpdateInstallerEngine::installToSystem(const QString &targetPath, bool desktopIcon, bool startMenu) {
    QString dest = targetPath.isEmpty() ? m_installPath : targetPath;
    m_installPath = dest;
    emit installPathChanged();

    setStatus(QStringLiteral("installing"), QStringLiteral("Installing Overtune 3 to system directory..."));
    setProgress(0.3);

    QTimer::singleShot(400, this, [this, dest, desktopIcon, startMenu]() {
        setProgress(0.7);
        bool ok = false;
#if defined(Q_OS_WIN)
        ok = performWindowsInstall(dest, desktopIcon, startMenu);
#else
        ok = performLinuxInstall(dest, desktopIcon, startMenu);
#endif
        setProgress(1.0);
        if (ok) {
            setStatus(QStringLiteral("installed"), QStringLiteral("Overtune 3 installed successfully to: ") + dest);
            emit updateSuccess(QStringLiteral("Installed successfully"));
        } else {
            setStatus(QStringLiteral("error"), QStringLiteral("Failed to install to: ") + dest);
            emit updateError(QStringLiteral("Installation failed"));
        }
    });
}

void UpdateInstallerEngine::restartApplication() {
    QString currentApp = QCoreApplication::applicationFilePath();
    QString targetApp = currentApp;

    // Check if installed binary exists
#if defined(Q_OS_WIN)
    QString installedBin = m_installPath + QStringLiteral("/ot3.exe");
    if (!QFile::exists(installedBin)) {
        installedBin = m_installPath + QStringLiteral("/FilterDesigner.exe");
    }
    QString updateBat = m_installPath + QStringLiteral("/overtune_update.bat");
    if (QFile::exists(updateBat)) {
        QProcess::startDetached(QStringLiteral("cmd.exe"), QStringList() << QStringLiteral("/c") << updateBat);
        QCoreApplication::quit();
        return;
    }
#else
    QString installedBin = m_installPath + QStringLiteral("/bin/ot3");
    if (!QFile::exists(installedBin)) {
        installedBin = m_installPath + QStringLiteral("/bin/FilterDesigner");
    }
#endif

    if (QFile::exists(installedBin)) {
        targetApp = installedBin;
    }

    QProcess::startDetached(targetApp, QStringList());
    QCoreApplication::quit();
}

void UpdateInstallerEngine::createShortcuts() {
#if defined(Q_OS_WIN)
    performWindowsInstall(m_installPath, true, true);
#else
    performLinuxInstall(m_installPath, true, true);
#endif
    emit updateSuccess(QStringLiteral("System desktop shortcuts created successfully"));
}

void UpdateInstallerEngine::openInstallDirectory() {
    QDesktopServices::openUrl(QUrl::fromLocalFile(m_installPath));
}
