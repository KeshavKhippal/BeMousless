#!/usr/bin/env bash
set -Eeuo pipefail

AUTOHOTKEY_VERSION="1.1.37.02"
AUTOHOTKEY_SHA256="6F3663F7CDD25063C8C8728F5D9B07813CED8780522FD1F124BA539E2854215F"
DOWNLOAD_URL="https://github.com/AutoHotkey/AutoHotkey/releases/download/v${AUTOHOTKEY_VERSION}/AutoHotkey_${AUTOHOTKEY_VERSION}.zip"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${SCRIPT_DIR}/.tools/autohotkey-${AUTOHOTKEY_VERSION}"
ARCHIVE_PATH="${TMPDIR:-/tmp}/AutoHotkey_${AUTOHOTKEY_VERSION}.zip"
SCRIPT_PATH="${SCRIPT_DIR}/BeMousless.ahk"
WINE_PREFIX="${WINEPREFIX:-${HOME}/.local/share/mouseless/wine}"

if [[ ! -f "${SCRIPT_PATH}" ]]; then
    echo "BeMousless.ahk was not found next to install.sh." >&2
    exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

install_dependencies() {
    if command -v apt-get >/dev/null 2>&1; then
        ${SUDO} apt-get update
        ${SUDO} apt-get install -y coreutils curl unzip wine
    elif command -v dnf >/dev/null 2>&1; then
        ${SUDO} dnf install -y coreutils curl unzip wine
    elif command -v pacman >/dev/null 2>&1; then
        ${SUDO} pacman -Sy --needed --noconfirm coreutils curl unzip wine
    else
        echo "Unsupported Linux package manager. Install curl, unzip, and Wine, then run this script again." >&2
        exit 1
    fi
}

if ! command -v wine >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1 || ! command -v sha256sum >/dev/null 2>&1; then
    echo "Installing Linux dependencies..."
    install_dependencies
fi

AHK_EXECUTABLE="${TOOLS_DIR}/AutoHotkeyU32.exe"
if [[ ! -f "${AHK_EXECUTABLE}" ]]; then
    mkdir -p "${TOOLS_DIR}"
    echo "Downloading AutoHotkey ${AUTOHOTKEY_VERSION}..."
    curl --fail --location --silent --show-error "${DOWNLOAD_URL}" --output "${ARCHIVE_PATH}"
    ACTUAL_SHA256="$(sha256sum "${ARCHIVE_PATH}" | awk '{print $1}')"
    if [[ "${ACTUAL_SHA256}" != "${AUTOHOTKEY_SHA256}" ]]; then
        rm -f "${ARCHIVE_PATH}"
        echo "AutoHotkey archive checksum verification failed." >&2
        exit 1
    fi
    echo "Installing AutoHotkey ${AUTOHOTKEY_VERSION} locally..."
    unzip -q -o "${ARCHIVE_PATH}" -d "${TOOLS_DIR}"
fi

if [[ ! -f "${AHK_EXECUTABLE}" ]]; then
    echo "AutoHotkey ${AUTOHOTKEY_VERSION} was downloaded, but AutoHotkeyU32.exe was not found." >&2
    exit 1
fi

mkdir -p "${WINE_PREFIX}"
echo "Starting BeMousless.ahk with AutoHotkey ${AUTOHOTKEY_VERSION} through Wine..."
WINEPREFIX="${WINE_PREFIX}" nohup wine "${AHK_EXECUTABLE}" "${SCRIPT_PATH}" >/dev/null 2>&1 &
echo "Mouseless is running. Stop it from the Wine tray icon or with: pkill -f AutoHotkeyU32.exe"