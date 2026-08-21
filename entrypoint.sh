#!/usr/bin/env bash

set -euo pipefail

export GITHUB="true"

GITHUB_ACTION_PATH="${GITHUB_ACTION_PATH%/}"
DRONE_SSH_RELEASE_URL="${DRONE_SSH_RELEASE_URL:-https://github.com/appleboy/drone-ssh/releases/download}"
DRONE_SSH_VERSION="${DRONE_SSH_VERSION:-1.8.4}"

# Error codes
readonly ERR_UNKNOWN_PLATFORM=2
readonly ERR_UNKNOWN_ARCH=3
readonly ERR_DOWNLOAD_FAILED=4
readonly ERR_INVALID_BINARY=5
readonly ERR_VERSION_CHECK_FAILED=6

function log_error() {
  echo "$1" >&2
  exit "$2"
}

function validate_non_negative_integer() {
  local name="$1"
  local value="$2"

  if [[ ! "${value}" =~ ^[0-9]+$ ]]; then
    log_error "${name} must be a non-negative integer, got: ${value}" 1
  fi
}

function is_retryable_connection_failure() {
  local output="$1"

  [[ "${output}" =~ dial[[:space:]]+tcp ]] || \
  [[ "${output}" =~ i/o[[:space:]]+timeout ]] || \
  [[ "${output}" =~ connection[[:space:]]+refused ]] || \
  [[ "${output}" =~ connection[[:space:]]+reset ]] || \
  [[ "${output}" =~ connection[[:space:]]+timed[[:space:]]+out ]] || \
  [[ "${output}" =~ no[[:space:]]+route[[:space:]]+to[[:space:]]+host ]] || \
  [[ "${output}" =~ network[[:space:]]+is[[:space:]]+unreachable ]] || \
  [[ "${output}" =~ no[[:space:]]+such[[:space:]]+host ]] || \
  [[ "${output}" =~ ssh:[[:space:]]+handshake[[:space:]]+failed ]]
}

function run_ssh_command() {
  local status=0
  local stderr=""

  if [[ "${INPUT_CAPTURE_STDOUT}" == 'true' ]]; then
    echo 'stdout<<EOF' >> "${GITHUB_OUTPUT}"
    exec 3>&1
    set +e
    stderr="$(
      {
        "${TARGET}" "$@" 1> >(tee -a "${GITHUB_OUTPUT}" >&3)
      } 2>&1 | tee /dev/stderr
    )"
    status="${PIPESTATUS[0]}"
    set -e
    exec 3>&-
    echo 'EOF' >> "${GITHUB_OUTPUT}"
    RUN_SSH_OUTPUT="${stderr}"
    return "${status}"
  else
    exec 3>&1
    set +e
    stderr="$(
      {
        "${TARGET}" "$@" 1>&3
      } 2>&1 | tee /dev/stderr
    )"
    status="${PIPESTATUS[0]}"
    set -e
    exec 3>&-
    RUN_SSH_OUTPUT="${stderr}"
    return "${status}"
  fi
}

function run_ssh_command_with_retry() {
  local retries="${INPUT_RETRY_ATTEMPTS:-0}"
  local delay="${INPUT_RETRY_DELAY:-0}"
  local max_attempts
  local attempt=1
  local status=0
  RUN_SSH_OUTPUT=""

  validate_non_negative_integer "retry_attempts" "${retries}"

  max_attempts=$((retries + 1))

  while true; do
    if (( retries > 0 )); then
      echo "SSH command attempt ${attempt}/${max_attempts}"
    fi

    run_ssh_command "$@"
    status="$?"

    if (( status == 0 )); then
      return 0
    fi

    if (( attempt >= max_attempts )); then
      return "${status}"
    fi

    if ! is_retryable_connection_failure "${RUN_SSH_OUTPUT}"; then
      return "${status}"
    fi

    attempt=$((attempt + 1))

    if [[ "${delay}" != "0" && "${delay}" != "0s" ]]; then
      sleep "${delay}"
    fi
  done
}

function detect_client_info() {
  CLIENT_PLATFORM="${SSH_CLIENT_OS:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
  CLIENT_ARCH="${SSH_CLIENT_ARCH:-$(uname -m)}"

  case "${CLIENT_PLATFORM}" in
  darwin | linux | windows) ;;
  # Git Bash / MSYS2 / Cygwin on Windows runners report e.g. MINGW64_NT-10.0
  mingw* | msys* | cygwin*) CLIENT_PLATFORM="windows" ;;
  *) log_error "Unknown or unsupported platform: ${CLIENT_PLATFORM}. Supported platforms are Linux, Darwin, and Windows." "${ERR_UNKNOWN_PLATFORM}" ;;
  esac

  case "${CLIENT_ARCH}" in
  x86_64* | i?86_64* | amd64*) CLIENT_ARCH="amd64" ;;
  aarch64* | arm64*) CLIENT_ARCH="arm64" ;;
  *) log_error "Unknown or unsupported architecture: ${CLIENT_ARCH}. Supported architectures are x86_64, i686, and arm64." "${ERR_UNKNOWN_ARCH}" ;;
  esac
}

detect_client_info
DOWNLOAD_URL_PREFIX="${DRONE_SSH_RELEASE_URL}/v${DRONE_SSH_VERSION}"
CLIENT_BINARY="drone-ssh-${DRONE_SSH_VERSION}-${CLIENT_PLATFORM}-${CLIENT_ARCH}"
# Windows release assets are published with an .exe suffix
if [[ "${CLIENT_PLATFORM}" == "windows" ]]; then
  CLIENT_BINARY="${CLIENT_BINARY}.exe"
fi
TARGET="${GITHUB_ACTION_PATH}/${CLIENT_BINARY}"

# Check if binary already exists and is executable (caching)
if [[ -f "${TARGET}" ]] && [[ -x "${TARGET}" ]]; then
  echo "Binary ${CLIENT_BINARY} already exists, skipping download"
else
  echo "Downloading ${CLIENT_BINARY} from ${DOWNLOAD_URL_PREFIX}"
  INSECURE_OPTION=""
  if [[ "${INPUT_CURL_INSECURE}" == 'true' ]]; then
    INSECURE_OPTION="--insecure"
  fi

  # Download with better error handling
  if ! curl -fsSL --retry 5 --keepalive-time 2 --location ${INSECURE_OPTION} \
    "${DOWNLOAD_URL_PREFIX}/${CLIENT_BINARY}" -o "${TARGET}"; then
    log_error "Failed to download ${CLIENT_BINARY} from ${DOWNLOAD_URL_PREFIX}. Please check the URL and your network connection." "${ERR_DOWNLOAD_FAILED}"
  fi

  # Validate downloaded file
  if [[ ! -f "${TARGET}" ]] || [[ ! -s "${TARGET}" ]]; then
    log_error "Downloaded file is missing or empty: ${TARGET}" "${ERR_INVALID_BINARY}"
  fi

  # Verify checksum; container jobs may lack shasum (Perl) or sha256sum, so
  # detect an available tool and skip verification with a warning if none exists
  SHA256_CMD=""
  if command -v shasum >/dev/null 2>&1; then
    SHA256_CMD="shasum -a 256"
  elif command -v sha256sum >/dev/null 2>&1; then
    SHA256_CMD="sha256sum"
  else
    echo "Warning: neither shasum nor sha256sum is available, skipping checksum verification" >&2
  fi

  if [[ -n "${SHA256_CMD}" ]]; then
    CHECKSUMS_FILE="${GITHUB_ACTION_PATH}/checksums.txt"
    if ! curl -fsSL --retry 5 --keepalive-time 2 --location ${INSECURE_OPTION} \
      "${DOWNLOAD_URL_PREFIX}/checksums.txt" -o "${CHECKSUMS_FILE}"; then
      log_error "Failed to download checksums.txt from ${DOWNLOAD_URL_PREFIX}." "${ERR_DOWNLOAD_FAILED}"
    fi

    EXPECTED_CHECKSUM=$(awk -v bin="${CLIENT_BINARY}" '$2 == bin {print $1}' "${CHECKSUMS_FILE}")
    if [[ -z "${EXPECTED_CHECKSUM}" ]]; then
      log_error "No checksum entry found for ${CLIENT_BINARY} in checksums.txt." "${ERR_INVALID_BINARY}"
    fi

    ACTUAL_CHECKSUM=$(${SHA256_CMD} "${TARGET}" | awk '{print $1}')
    if [[ "${ACTUAL_CHECKSUM}" != "${EXPECTED_CHECKSUM}" ]]; then
      log_error "Checksum verification failed for ${CLIENT_BINARY}: expected ${EXPECTED_CHECKSUM}, got ${ACTUAL_CHECKSUM}." "${ERR_INVALID_BINARY}"
    fi
    echo "Checksum verification passed for ${CLIENT_BINARY}"
    rm -f "${CHECKSUMS_FILE}"
  fi

  chmod +x "${TARGET}"
fi

echo "======= CLI Version Information ======="
if ! "${TARGET}" --version; then
  log_error "Failed to execute ${TARGET} --version. The binary may be corrupted." "${ERR_VERSION_CHECK_FAILED}"
fi
echo "======================================="
run_ssh_command_with_retry "$@"
