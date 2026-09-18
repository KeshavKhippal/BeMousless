#!/usr/bin/env bash
set -Eeuo pipefail

REPOSITORY_URL="https://github.com/KeshavKhippal/BeMousless/archive/refs/heads/main.zip"
INSTALL_DIRECTORY="${XDG_DATA_HOME:-${HOME}/.local/share}/bemousless"
ARCHIVE_PATH="${TMPDIR:-/tmp}/BeMousless-main.zip"
EXTRACT_DIRECTORY="${TMPDIR:-/tmp}/bemousless-bootstrap-$$"

if [[ "${EUID}" -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

install_dependencies() {
    if command -v apt-get >/dev/null 2>&1; then
        ${SUDO} apt-get update
        ${SUDO} apt-get install -y bash coreutils curl unzip wine
    elif command -v dnf >/dev/null 2>&1; then
        ${SUDO} dnf install -y bash coreutils curl unzip wine
    elif command -v pacman >/dev/null 2>&1; then
        ${SUDO} pacman -Sy --needed --noconfirm bash coreutils curl unzip wine
    else
        echo "Unsupported Linux package manager. Install Wine, curl, unzip, and coreutils, then run again." >&2
        exit 1
    fi
}

download() {
    local url="$1"
    local destination="$2"
    if command -v curl >/dev/null 2>&1; then
        curl --fail --location --silent --show-error "${url}" --output "${destination}"
    elif command -v wget >/dev/null 2>&1; then
        wget --quiet --output-document="${destination}" "${url}"
    else
        echo "curl or wget is required to start the bootstrap command." >&2
        exit 1
    fi
}

if ! command -v wine >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1 || ! command -v sha256sum >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
    echo "Installing Linux dependencies..."
    install_dependencies
fi

cleanup() {
    rm -rf "${EXTRACT_DIRECTORY}" "${ARCHIVE_PATH}"
}
trap cleanup EXIT

rm -rf "${EXTRACT_DIRECTORY}"
mkdir -p "${EXTRACT_DIRECTORY}"
echo "Downloading BeMousless..."
download "${REPOSITORY_URL}" "${ARCHIVE_PATH}"
unzip -q -o "${ARCHIVE_PATH}" -d "${EXTRACT_DIRECTORY}"

SOURCE_DIRECTORY="${EXTRACT_DIRECTORY}/BeMousless-main"
if [[ ! -f "${SOURCE_DIRECTORY}/install.sh" ]]; then
    echo "The downloaded BeMousless repository is missing install.sh." >&2
    exit 1
fi

mkdir -p "${INSTALL_DIRECTORY}"
rm -rf "${INSTALL_DIRECTORY}/source"
mv "${SOURCE_DIRECTORY}" "${INSTALL_DIRECTORY}/source"
cd "${INSTALL_DIRECTORY}/source"
bash ./install.sh
