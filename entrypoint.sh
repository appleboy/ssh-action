#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export GITHUB="true"

GITHUB_ACTION_PATH="${GITHUB_ACTION_PATH%/}"
DRONE_SSH_RELEASE_URL="${DRONE_SSH_RELEASE_URL:-https://github.com/appleboy/drone-ssh/releases/download}"
DRONE_SSH_VERSION="${DRONE_SSH_VERSION:-1.8.1}"

function log_error() {
  echo "$1" >&2
  exit "$2"
}

function detect_client_info() {
  CLIENT_PLATFORM="${SSH_CLIENT_OS:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
  CLIENT_ARCH="${SSH_CLIENT_ARCH:-$(uname -m)}"

  case "${CLIENT_PLATFORM}" in
  darwin | linux | windows) ;;
  *) log_error "Unknown or unsupported platform: ${CLIENT_PLATFORM}. Supported platforms are Linux, Darwin, and Windows." 2 ;;
  esac

  case "${CLIENT_ARCH}" in
  x86_64* | i?86_64* | amd64*) CLIENT_ARCH="amd64" ;;
  aarch64* | arm64*) CLIENT_ARCH="arm64" ;;
  *) log_error "Unknown or unsupported architecture: ${CLIENT_ARCH}. Supported architectures are x86_64, i686, and arm64." 3 ;;
  esac
}

detect_client_info
DOWNLOAD_URL_PREFIX="${DRONE_SSH_RELEASE_URL}/v${DRONE_SSH_VERSION}"
CLIENT_BINARY="drone-ssh-${DRONE_SSH_VERSION}-${CLIENT_PLATFORM}-${CLIENT_ARCH}"
TARGET="${GITHUB_ACTION_PATH}/${CLIENT_BINARY}"
echo "Downloading ${CLIENT_BINARY} from ${DOWNLOAD_URL_PREFIX}"
curl -fsSL --retry 5 --keepalive-time 2 "${DOWNLOAD_URL_PREFIX}/${CLIENT_BINARY}" -o "${TARGET}"
chmod +x "${TARGET}"

echo "======= CLI Version Information ======="
"${TARGET}" --version
echo "======================================="
if [[ "${INPUT_CAPTURE_STDOUT}" == 'true' ]]; then
  {
    echo 'stdout<<EOF'
    "${TARGET}" "$@" | tee -a "${GITHUB_OUTPUT}"
    echo 'EOF'
  } >>"${GITHUB_OUTPUT}"
else
  "${TARGET}" "$@"
fi
