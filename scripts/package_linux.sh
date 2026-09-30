#!/usr/bin/env bash
# package_linux.sh — Packages Overtune 3 into a standalone distribution tarball & AppDir for Linux
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
PKG_NAME="overtune3-linux-x86_64"
STAGE_DIR="${DIST_DIR}/${PKG_NAME}"

echo "Building and packaging Overtune 3 for Linux..."
"${ROOT_DIR}/build.sh"

rm -rf "${STAGE_DIR}" "${DIST_DIR}/${PKG_NAME}.tar.gz"
mkdir -p "${STAGE_DIR}/bin" "${STAGE_DIR}/assets" "${STAGE_DIR}/scripts"

# Copy binary & assets
if [[ -f "${ROOT_DIR}/build/bin/ot3" ]]; then
    cp "${ROOT_DIR}/build/bin/ot3" "${STAGE_DIR}/bin/ot3"
elif [[ -f "${ROOT_DIR}/build/bin/FilterDesigner" ]]; then
    cp "${ROOT_DIR}/build/bin/FilterDesigner" "${STAGE_DIR}/bin/ot3"
fi
chmod +x "${STAGE_DIR}/bin/ot3"
ln -sf "ot3" "${STAGE_DIR}/bin/FilterDesigner"

cp "${ROOT_DIR}/assets/logo.png" "${STAGE_DIR}/assets/"
cp "${ROOT_DIR}/scripts/install_linux.sh" "${STAGE_DIR}/"
cp "${ROOT_DIR}/README.md" "${STAGE_DIR}/"

# Launcher wrapper script in bundle root
cat > "${STAGE_DIR}/ot3.sh" << 'EOF'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export QT_QPA_PLATFORMTHEME="generic"
exec "${DIR}/bin/ot3" "$@"
EOF

# Compatibility wrapper overtune3.sh
cat > "${STAGE_DIR}/overtune3.sh" << 'EOF'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${DIR}/ot3.sh" "$@"
EOF
chmod +x "${STAGE_DIR}/ot3.sh" "${STAGE_DIR}/overtune3.sh" "${STAGE_DIR}/install_linux.sh"

# Archive
cd "${DIST_DIR}"
tar -czf "${PKG_NAME}.tar.gz" "${PKG_NAME}"
echo "✓ Linux package created: ${DIST_DIR}/${PKG_NAME}.tar.gz"
