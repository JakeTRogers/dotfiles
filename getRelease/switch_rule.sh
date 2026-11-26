#!/usr/bin/env bash
# Sourced by getRelease's install.sh and configure.sh.

# where getRelease and the Tools it installs live on a machine that switches
readonly home_bin_dir="${HOME}/.local/bin"

# machine_switches succeeds when getRelease and the Tools it installs belong in
# ~/.local/bin on this machine: getRelease has no config file of its own, only
# none at all or one whose installDir is already ~/.local/bin, as configure.sh
# writes, and none of its recorded binaries still exists outside ~/.local/bin.
# Any other machine keeps its getRelease config, history and binaries as they
# are, until getRelease can move recorded installs (JakeTRogers/getRelease#47).
# See docs/adr/0001-getrelease-tools-install-in-home.md.
machine_switches() {
  # getRelease's own paths on Linux, from its internal/config/paths.go
  local config_file="${XDG_CONFIG_HOME:-${HOME}/.config}/getRelease/config.yaml"
  local history_file="${XDG_DATA_HOME:-${HOME}/.local/share}/getRelease/history.json"
  local path

  if [[ -e "${config_file}" && "$(config_install_dir "${config_file}")" != "${home_bin_dir}" ]]; then
    return 1
  fi
  if [[ ! -f "${history_file}" ]]; then
    return 0
  fi

  # getRelease writes history.json indented, one "installPath" per line
  while IFS= read -r path; do
    if [[ -e "${path}" && "${path%/*}" != "${home_bin_dir}" ]]; then
      return 1
    fi
  done < <(sed -n 's/^[[:space:]]*"installPath":[[:space:]]*"\(.*\)",\{0,1\}$/\1/p' "${history_file}")

  return 0
}

# config_install_dir prints the installDir that the getRelease config file $1
# sets, the way getRelease reads it, or nothing when it sets none. getRelease
# writes the file with Go's yaml.v3: one top-level "key: value" per line, the
# value quoted only when YAML needs it. Like Viper, it matches keys ignoring
# case, and its internal/config ExpandPath expands a leading ~/ and drops a
# trailing slash. A subshell keeps nocasematch from reaching the caller.
config_install_dir() (
  shopt -s nocasematch
  local line dir=''

  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ "${line}" =~ ^installDir[[:space:]]*:[[:space:]]*(.*)$ ]]; then
      dir="${BASH_REMATCH[1]}"
    fi
  done < "$1"

  case "${dir}" in
    \"*)
      dir="${dir#\"}"
      dir="${dir%%\"*}"
      ;;
    \'*)
      dir="${dir#\'}"
      dir="${dir%%\'*}"
      ;;
    *)
      # a plain value ends at a comment or trailing blanks
      dir="${dir%%[[:space:]]#*}"
      dir="${dir%"${dir##*[![:space:]]}"}"
      ;;
  esac

  if [[ "${dir}" == \~/* ]]; then
    dir="${HOME}/${dir#\~/}"
  fi
  while [[ "${dir}" == ?*/ ]]; do
    dir="${dir%/}"
  done

  printf '%s\n' "${dir}"
)
