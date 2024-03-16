#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export GITHUB="true"

DRONE_SSH_RELEASE_URL="${DRONE_SSH_RELEASE_URL:-https://github.com/appleboy/drone-ssh/releases/download}"
DRONE_SSH_VERSION="${DRONE_SSH_VERSION:-1.7.4}"

function detect_client_info() {
  if [ -n "${SSH_CLIENT_OS-}" ]; then
    CLIENT_PLATFORM="${SSH_CLIENT_OS}"
  else
    local kernel
    kernel="$(uname -s)"
    case "${kernel}" in
      Darwin)
        CLIENT_PLATFORM="darwin"
        ;;
      Linux)
        CLIENT_PLATFORM="linux"
        ;;
      Windows)
        CLIENT_PLATFORM="windows"
        ;;
      *)
        echo "Unknown, unsupported platform: ${kernel}." >&2
        echo "Supported platforms: Linux, Darwin and Windows." >&2
        echo "Bailing out." >&2
        exit 2
    esac
  fi

  if [ -n "${SSH_CLIENT_ARCH-}" ]; then
    CLIENT_ARCH="${SSH_CLIENT_ARCH}"
  else
    # TODO: migrate the kube::util::host_platform function out of hack/lib and
    # use it here.
    local machine
    machine="$(uname -m)"
    case "${machine}" in
      x86_64*|i?86_64*|amd64*)
        CLIENT_ARCH="amd64"
        ;;
      aarch64*|arm64*)
        CLIENT_ARCH="arm64"
        ;;
      *)
        echo "Unknown, unsupported architecture (${machine})." >&2
        echo "Supported architectures x86_64, i686, arm64." >&2
        echo "Bailing out." >&2
        exit 3
        ;;
    esac
  fi
}

detect_client_info
DOWNLOAD_URL_PREFIX="${DRONE_SSH_RELEASE_URL}/v${DRONE_SSH_VERSION}"
CLIENT_BINARY="drone-ssh-${DRONE_SSH_VERSION}-${CLIENT_PLATFORM}-${CLIENT_ARCH}"
echo "Will download ${CLIENT_BINARY} from ${DOWNLOAD_URL_PREFIX}"
curl -fL --retry 3 --keepalive-time 2 "${DOWNLOAD_URL_PREFIX}/${CLIENT_BINARY}" -o ${GITHUB_ACTION_PATH}/drone-ssh
chmod +x ${GITHUB_ACTION_PATH}drone-ssh
sh -c "${GITHUB_ACTION_PATH}/drone-ssh $*"
