#!/usr/bin/env bash
# Build gitstatusd for x86_64 Linux with relativeworktrees.patch applied.
#
#   omz/gitstatusd/build.sh OUT_DIR
#
# Fetches the pinned gitstatus commit and the libgit2 fork commit its
# build.info names, patches libgit2, and runs gitstatus's own build script in
# the Alpine image upstream builds with, so the binary is static (musl) and
# runs on any x86_64 Linux. Writes OUT_DIR/gitstatusd-linux-x86_64. Needs git
# and podman or docker; set CONTAINER_ENGINE to choose one.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly here
# the image gitstatus's build script uses for x86_64 (`build -d`)
readonly build_image='docker.io/library/alpine:3.11.6'

die() {
  echo "🔴 $*" >&2
  exit 1
}

# fetch_commit URL REF COMMIT DIR: fetch REF into DIR and check out COMMIT,
# failing if REF does not resolve to COMMIT
fetch_commit() {
  local url="$1" ref="$2" commit="$3" dir="$4" actual
  git init -q "${dir}"
  git -C "${dir}" fetch -q --depth 1 "${url}" "${ref}"
  actual="$(git -C "${dir}" rev-parse 'FETCH_HEAD^{commit}')"
  [[ "${actual}" == "${commit}" ]] || die "${url} ${ref} is ${actual}, expected ${commit}"
  git -C "${dir}" -c advice.detachedHead=false checkout -q FETCH_HEAD
}

# read_var FILE NAME: print NAME from a file of sh assignments, without
# running the rest of it in this shell
read_var() {
  # shellcheck disable=SC1090  # the file is chosen at run time
  (. "$1" && eval "printf '%s\n' \"\${$2}\"")
}

out_dir="${1:?usage: build.sh OUT_DIR}"
[[ "$(uname -m)" == x86_64 ]] || die "build.sh builds on x86_64 only, not $(uname -m)"
engine="${CONTAINER_ENGINE:-$(command -v podman || command -v docker || true)}"
[[ -n "${engine}" ]] || die 'build.sh needs podman or docker'

gitstatus_repo="$(read_var "${here}/gitstatusd.env" gitstatus_repo)"
gitstatus_commit="$(read_var "${here}/gitstatusd.env" gitstatus_commit)"

work="$(mktemp -d)"
# with rootful docker the build output is root-owned and cannot be removed;
# leave it in the temp directory rather than fail a finished build
trap 'rm -rf -- "${work}" 2> /dev/null || true' EXIT

echo "Fetching gitstatus ${gitstatus_commit}"
fetch_commit "${gitstatus_repo}" "${gitstatus_commit}" "${gitstatus_commit}" "${work}/gitstatus"
build_info="${work}/gitstatus/build.info"
gitstatus_version="$(read_var "${build_info}" gitstatus_version)"
libgit2_version="$(read_var "${build_info}" libgit2_version)"
# the fork tags each commit it pins as tag-<commit>
[[ "${libgit2_version}" == tag-* ]] || die "unexpected libgit2_version in build.info: ${libgit2_version}"

echo "Fetching libgit2 ${libgit2_version}"
libgit2_dir="${work}/libgit2-${libgit2_version}"
fetch_commit https://github.com/romkatv/libgit2.git "refs/tags/${libgit2_version}" \
  "${libgit2_version#tag-}" "${libgit2_dir}"
git -C "${libgit2_dir}" apply "${here}/relativeworktrees.patch"

# gitstatus's build script unpacks deps/libgit2-<version>.tar.gz and checks it
# against libgit2_sha256 in build.info, so pack the patched tree under that
# name and pin its hash
mkdir -p "${work}/gitstatus/deps"
tarball="${work}/gitstatus/deps/libgit2-${libgit2_version}.tar.gz"
tar -czf "${tarball}" --exclude=.git -C "${work}" "libgit2-${libgit2_version}"
sed -i "s/^libgit2_sha256=.*/libgit2_sha256=\"$(sha256sum "${tarball}" | cut -d' ' -f1)\"/" "${build_info}"

echo "Building gitstatusd ${gitstatus_version} with ${engine##*/}"
# :Z relabels the mount for SELinux hosts such as Fedora; elsewhere it is a no-op
"${engine}" run --rm -v "${work}/gitstatus:/out:Z" -w /out "${build_image}" ./build -s

mkdir -p "${out_dir}"
install -m 755 "${work}/gitstatus/usrbin/gitstatusd" "${out_dir}/gitstatusd-linux-x86_64"
echo "🟢 built ${out_dir}/gitstatusd-linux-x86_64 ($("${out_dir}/gitstatusd-linux-x86_64" --version))"
