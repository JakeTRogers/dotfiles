#!/usr/bin/env bash

set -euo pipefail

# getRelease and the Tools it installs live in ~/.local/bin and install without
# sudo on every machine, so they survive a Rebuild of a Dev container with a
# Home volume. See docs/adr/0001-getrelease-tools-install-in-home.md.
#
# bin/dotfiles runs a Tool's install.sh only when its command is not on PATH,
# so on a machine that already has getRelease only this Configure step runs.
# That is why it also installs, upgrades and removes binaries: it makes sure
# the getRelease on PATH can relocate, then moves whatever getRelease installed
# elsewhere into ~/.local/bin.
readonly home_bin_dir="${HOME}/.local/bin"
readonly install_command='install -m 755 {source} {target}'
# where getRelease's old install.sh put getRelease, with sudo and unrecorded
readonly old_install_path='/usr/local/bin/getRelease'

# The patterns that read getRelease's output. `getRelease version` prints
# "getRelease 1.7.0 (linux/amd64)". The JSON comes from Go's json.Encoder with
# SetIndent("", "  "), one field per line: in relocate's report the top-level
# keys sit at 2 spaces, each binary's fields at 6 and the end of each binary at
# 4, and in `history list` installPath is the last field of each binary.
# Values stay JSON-escaped.
readonly version_re='^getRelease ([0-9]+)\.([0-9]+)\.'
readonly install_path_re='^ +"installPath": "(.*)"$'
readonly entry_field_re='^      "([a-zA-Z]+)": "(.*)",?$'
readonly entry_end_re='^    },?$'
readonly install_dir_updated_re='^  "installDirUpdated": (true|false),?$'

# has_relocate succeeds when the getRelease on PATH is 1.7.0 or later, the
# first release with relocate
has_relocate() {
  local version

  version="$(getRelease version 2> /dev/null)" || return 1
  [[ "${version}" =~ ${version_re} ]] || return 1
  (( BASH_REMATCH[1] > 1 || (BASH_REMATCH[1] == 1 && BASH_REMATCH[2] >= 7) ))
}

# has_json_escape succeeds when getRelease's JSON output, from Go's
# encoding/json, escapes a character of $1: ", \, a control character, &, <,
# >, U+2028 or U+2029. The path then never matches the text that output holds.
has_json_escape() {
  [[ "$1" == *[\"\\\&\<\>[:cntrl:]]* || "$1" == *$'\xe2\x80\xa8'* || "$1" == *$'\xe2\x80\xa9'* ]]
}

# is_recorded succeeds when the history $1, as `getRelease history list
# --format json` prints it, records a binary at path $2, which must have no
# character that has_json_escape finds
is_recorded() {
  local line

  while IFS= read -r line; do
    if [[ "${line}" =~ ${install_path_re} && "${BASH_REMATCH[1]}" == "$2" ]]; then
      return 0
    fi
  done <<< "$1"
  return 1
}

# remove_old_copy removes, with $elevate, the old copy at $1 of a binary that
# now lives in ~/.local/bin, such as one in /usr/local/bin, which needs sudo
remove_old_copy() {
  # shellcheck disable=SC2086,SC2154  # $elevate is exported by install.sh and must word-split
  $elevate rm -f -- "$1"
}

# print_entry prints relocate's outcome for one binary, from the fields of its
# report entry in the associative array named $1
print_entry() {
  local -n fields="$1"
  local package="${fields[package]:-}" from="${fields[from]:-}" to="${fields[to]:-}" error="${fields[error]:-}"

  case "${fields[status]:-}" in
    in-place)
      ;;
    moved)
      echo "🟢 getRelease moved ${package}: ${from} -> ${to}"
      ;;
    remove-failed)
      echo "🔴 getRelease moved ${package}: ${from} -> ${to}, but could not remove the old copy; remove it yourself: ${fields[hint]:-}"
      ;;
    missing)
      echo "⚠️ getRelease skipped ${package}: ${from:-the recorded path} is missing; 'getRelease history prune' removes its record"
      ;;
    conflict)
      echo "🔴 getRelease skipped ${package}: conflict, ${to} already exists"
      ;;
    invalid-name)
      echo "🔴 getRelease skipped ${package}: ${error}"
      ;;
    install-failed)
      echo "🔴 getRelease failed ${package}: installing ${to}: ${error}"
      ;;
    *)
      echo "🔴 getRelease ${package}: ${fields[status]:-no status} ${error}"
      ;;
  esac
}

# make sure the getRelease on PATH can relocate, without ever putting a copy at
# ~/.local/bin/getRelease that relocate would then report as a conflict
getrelease_path="$(command -v getRelease)"
if has_json_escape "${getrelease_path}"; then
  echo "🔴 the Installer cannot tell whether getRelease's history records ${getrelease_path}, since getRelease escapes some of its characters; move getRelease to a path without \", \\, &, <, > or control characters and run the Installer again"
  exit 1
fi
# whether history records that getRelease decides what happens to it, so stop
# before anything is installed or removed when history cannot be read
if ! history_json="$(getRelease history list --format json)"; then
  echo "🔴 getRelease could not read its history, so the Installer changed nothing; fix $(getRelease history path) and run the Installer again"
  exit 1
fi

if is_recorded "${history_json}" "${getrelease_path}"; then
  # relocate moves it below. One too old to relocate is first upgraded where it
  # is, with its current installCommand; the Install step also trusts
  # releases/latest with no cooldown. A failed upgrade is reported by the check
  # that follows.
  has_relocate || getRelease upgrade JakeTRogers/getRelease --cooldown 0 || true
elif [[ "${getrelease_path}" != "${home_bin_dir}/getRelease" && "${getrelease_path}" != "${old_install_path}" ]]; then
  # relocate moves only what history records. The one unrecorded getRelease
  # outside ~/.local/bin that the Installer replaces is the one getRelease's
  # old install.sh put in /usr/local/bin; any other, such as one a package
  # manager installed, is not the Installer's to remove.
  echo "🔴 getRelease's history does not record ${getrelease_path}, so the Installer cannot move it into ${home_bin_dir}; remove it and run the Installer again"
  exit 1
elif [[ "${getrelease_path}" == "${old_install_path}" ]] || ! has_relocate; then
  # replace the unrecorded getRelease that getRelease's old install.sh put in
  # /usr/local/bin, or one in ~/.local/bin too old to relocate, with the latest
  # release in ~/.local/bin, as a new install gets
  "${BASH_SOURCE[0]%/*}/install.sh"
  if [[ "${getrelease_path}" == "${old_install_path}" ]]; then
    remove_old_copy "${old_install_path}"
    echo "🟢 removed the old getRelease from ${old_install_path%/*}"
  fi
fi
hash -r
if ! has_relocate; then
  echo "🔴 $(getRelease version) at $(command -v getRelease) cannot relocate its binaries; upgrade it to 1.7.0 or later and run the Installer again"
  exit 1
fi

# move every recorded binary into ~/.local/bin. The sudo-free installCommand
# applies to this run only, so a blocked relocation leaves the saved one as it
# was and the machine can still upgrade with sudo.
report="$(GETRELEASE_INSTALLCOMMAND="${install_command}" getRelease relocate "${home_bin_dir}" --format json 2>&1)" || true

# what relocate did with installDir: unreported until its report says it
# updated it, or kept it because something blocked the move
install_dir_state=unreported
old_copies_remain=false
declare -A entry=()
while IFS= read -r line; do
  if [[ "${line}" =~ ${entry_field_re} ]]; then
    entry["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
  elif [[ "${line}" =~ ${entry_end_re} ]]; then
    # remove the old copy that relocate could not remove. A path with JSON
    # escapes is not the path on disk, so leave that one to the user.
    if [[ "${entry[status]:-}" == remove-failed && "${entry[from]:-}" != *\\* ]] &&
      remove_old_copy "${entry[from]}"; then
      entry[status]=moved
    fi
    print_entry entry
    if [[ "${entry[status]:-}" == remove-failed ]]; then
      old_copies_remain=true
    fi
    entry=()
  elif [[ "${line}" =~ ${install_dir_updated_re} ]]; then
    if [[ "${BASH_REMATCH[1]}" == true ]]; then
      install_dir_state=updated
    else
      install_dir_state=kept
    fi
  fi
done <<< "${report}"

# getRelease itself may have moved
hash -r

case "${install_dir_state}" in
  updated)
    # relocate set installDir itself, since nothing blocked the move
    ;;
  kept)
    echo "🔴 getRelease could not move every binary into ${home_bin_dir}. Fix the ones marked 🔴 above and run the Installer again; until then getRelease keeps its installDir and installCommand"
    exit 1
    ;;
  unreported)
    # relocate stopped before it could report, so show what it printed instead
    printf '%s\n' "${report}"
    echo "🔴 getRelease could not relocate its binaries into ${home_bin_dir}"
    exit 1
    ;;
esac

getRelease config set installCommand "${install_command}"

if [[ "${old_copies_remain}" == true ]]; then
  echo "🔴 getRelease moved every binary into ${home_bin_dir}, but old copies remain; remove them as shown above"
  exit 1
fi

echo "🟢 getRelease installs into ${home_bin_dir} without sudo"
