#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export QT_QPA_PLATFORMTHEME="generic"
exec "${DIR}/bin/ot3" "$@"
