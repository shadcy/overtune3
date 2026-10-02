#!/usr/bin/env bash
# install_linux.sh — Native Linux Installer for Overtune 3 DSP Filter Designer
# Supports user-level installation (~/.local) and system-wide installation (/opt)

set -euo pipefail

APP_NAME="Overtune 3"
APP_ID="overtune3"
BIN_NAME="ot3"
VERSION="3.2.4"

# Target directories
if [[ $EUID -eq 0 ]]; then
    INSTALL_DIR="/opt/${APP_ID}"
    BIN_DIR="/usr/local/bin"
    DESKTOP_DIR="/usr/share/applications"
    ICON_DIR="/usr/share/icons/hicolor"
    GLOBAL=true
else
    INSTALL_DIR="${HOME}/.local/share/${APP_ID}"
    BIN_DIR="${HOME}/.local/bin"
    DESKTOP_DIR="${HOME}/.local/share/applications"
    ICON_DIR="${HOME}/.local/share/icons/hicolor"
    GLOBAL=false
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║          Overtune 3 — Native Linux Installer            ║"
echo "║          Version: ${VERSION} (x86_64)                         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo

# Locate binary
SOURCE_BIN=""
if [[ -f "${ROOT_DIR}/build/bin/${BIN_NAME}" ]]; then
    SOURCE_BIN="${ROOT_DIR}/build/bin/${BIN_NAME}"
elif [[ -f "${ROOT_DIR}/build/bin/FilterDesigner" ]]; then
    SOURCE_BIN="${ROOT_DIR}/build/bin/FilterDesigner"
elif [[ -f "${SCRIPT_DIR}/${BIN_NAME}" ]]; then
    SOURCE_BIN="${SCRIPT_DIR}/${BIN_NAME}"
elif [[ -f "${SCRIPT_DIR}/bin/${BIN_NAME}" ]]; then
    SOURCE_BIN="${SCRIPT_DIR}/bin/${BIN_NAME}"
else
    echo "⚠️  Building Overtune 3 first..."
    "${ROOT_DIR}/build.sh"
    SOURCE_BIN="${ROOT_DIR}/build/bin/${BIN_NAME}"
fi

if [[ ! -f "${SOURCE_BIN}" ]]; then
    echo "❌ Error: Could not find compiled binary '${SOURCE_BIN}'"
    exit 1
fi

echo "Installing to: ${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}/bin"
mkdir -p "${INSTALL_DIR}/assets"
mkdir -p "${BIN_DIR}"
mkdir -p "${DESKTOP_DIR}"
mkdir -p "${ICON_DIR}/256x256/apps"
mkdir -p "${ICON_DIR}/scalable/apps"

# 1. Copy binary
echo "  → Installing application binary..."
cp -f "${SOURCE_BIN}" "${INSTALL_DIR}/bin/${BIN_NAME}"
chmod +x "${INSTALL_DIR}/bin/${BIN_NAME}"

# 2. Copy icons & assets
echo "  → Installing high-resolution application icons..."
ICON_SRC="${ROOT_DIR}/assets/logo.png"
if [[ -f "${ICON_SRC}" ]]; then
    cp -f "${ICON_SRC}" "${ICON_DIR}/256x256/apps/${APP_ID}.png"
    cp -f "${ICON_SRC}" "${INSTALL_DIR}/assets/${APP_ID}.png"
fi

# 3. Create desktop launcher entry
echo "  → Creating desktop application entry..."
DESKTOP_FILE="${DESKTOP_DIR}/${APP_ID}.desktop"
cat > "${DESKTOP_FILE}" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Overtune 3
GenericName=DSP Filter Designer & Live Audio Lab
Comment=Sub-millidecibel precision IIR/FIR filter design studio with Stage 2 verification
Exec="${INSTALL_DIR}/bin/${BIN_NAME}" %F
Icon=${APP_ID}
Terminal=false
StartupNotify=true
Categories=AudioVideo;Audio;Science;Engineering;Qt;
Keywords=filter;dsp;audio;iir;fir;biquad;equalizer;chebyshev;butterworth;
MimeType=application/x-overtune-filter;
EOF
chmod +x "${DESKTOP_FILE}"

# Optional Desktop shortcut if ~/Desktop exists
if [[ -d "${HOME}/Desktop" ]]; then
    cp -f "${DESKTOP_FILE}" "${HOME}/Desktop/${APP_ID}.desktop"
    chmod +x "${HOME}/Desktop/${APP_ID}.desktop"
fi

# 4. Command-line symlinks
echo "  → Registering command-line tools 'ot3' and '${APP_ID}'..."
ln -sf "${INSTALL_DIR}/bin/${BIN_NAME}" "${BIN_DIR}/ot3"
ln -sf "${INSTALL_DIR}/bin/${BIN_NAME}" "${BIN_DIR}/${APP_ID}"

# 5. Create uninstaller
echo "  → Creating uninstaller script..."
UNINSTALL_SCRIPT="${INSTALL_DIR}/uninstall.sh"
cat > "${UNINSTALL_SCRIPT}" <<EOF
#!/usr/bin/env bash
set -e
echo "Uninstalling Overtune 3..."
rm -f "${DESKTOP_DIR}/${APP_ID}.desktop"
rm -f "${HOME}/Desktop/${APP_ID}.desktop" 2>/dev/null || true
rm -f "${BIN_DIR}/ot3"
rm -f "${BIN_DIR}/${APP_ID}"
rm -f "${ICON_DIR}/256x256/apps/${APP_ID}.png"
rm -rf "${INSTALL_DIR}"
echo "Overtune 3 uninstalled successfully."
EOF
chmod +x "${UNINSTALL_SCRIPT}"

# Update desktop databases if tools exist
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${DESKTOP_DIR}" 2>/dev/null || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "${ICON_DIR}" 2>/dev/null || true
fi

echo
echo "✓ Installation complete!"
echo "  Launch Overtune 3 via your application menu or run '${APP_ID}' in terminal."
echo "  Installed at: ${INSTALL_DIR}"
echo "  Uninstaller:  ${UNINSTALL_SCRIPT}"
