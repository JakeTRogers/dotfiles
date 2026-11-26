#!/usr/bin/env bash

set -euo pipefail

# getRelease lives in ~/.local/bin, installed without sudo, on every machine.
# bin/dotfiles runs this only when getRelease is not on PATH, and configure.sh
# runs it to replace an unrecorded getRelease, so it always installs the latest
# release.
readonly install_dir="${HOME}/.local/bin"
readonly install_path="${install_dir}/getRelease"
readonly release_url_base='https://github.com/JakeTRogers/getRelease/releases/latest/download'

cleanup() {
  if [[ -n "${temp_dir:-}" && -d "${temp_dir}" ]]; then
    rm -rf "${temp_dir}"
  fi
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)
      printf '%s\n' 'x86_64'
      ;;
    aarch64|arm64)
      printf '%s\n' 'arm64'
      ;;
    *)
      echo "🔴 unsupported architecture: $(uname -m)"
      exit 1
      ;;
  esac
}

if [[ "$(uname -s)" != 'Linux' ]]; then
  echo '🔴 getRelease bootstrap is only supported on Linux'
  exit 1
fi

temp_dir="$(mktemp -d)"
trap cleanup EXIT

archive_name="getRelease_Linux_$(detect_arch).tar.gz"
readonly archive_name
readonly archive_url="${release_url_base}/${archive_name}"
readonly archive_path="${temp_dir}/${archive_name}"
readonly extract_dir="${temp_dir}/extract"
install_cmd="$(command -v install)"
readonly install_cmd

mkdir -p "${extract_dir}"

if ! curl -fsSL "${archive_url}" -o "${archive_path}"; then
  echo "🔴 failed to download ${archive_name} from ${archive_url}"
  exit 1
fi

# verify the archive against the release's published checksums before extracting
if ! curl -fsSL "${release_url_base}/checksums.txt" -o "${temp_dir}/checksums.txt"; then
  echo "🔴 failed to download checksums.txt from ${release_url_base}"
  exit 1
fi

if ! (cd "${temp_dir}" && sha256sum --check --quiet --ignore-missing checksums.txt); then
  echo "🔴 checksum verification failed for ${archive_name}"
  exit 1
fi

tar -xzf "${archive_path}" -C "${extract_dir}"
binary_path="$(find "${extract_dir}" -type f -name 'getRelease' -print -quit)"

if [[ -z "${binary_path}" ]]; then
  echo '🔴 getRelease binary not found in downloaded archive'
  exit 1
fi

mkdir -p "${install_dir}"
"${install_cmd}" -m 755 "${binary_path}" "${install_path}"

if [[ ! -x "${install_path}" ]]; then
  echo '🔴 getRelease install failed'
  exit 1
fi

if ! "${install_path}" version &> /dev/null; then
  echo '🔴 installed getRelease binary failed validation'
  exit 1
fi

echo '🟢 getRelease installed'
