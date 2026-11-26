#!/usr/bin/env bash

set -euo pipefail

source "${BASH_SOURCE[0]%/*}/switch_rule.sh"

# point getRelease at ~/.local/bin, without sudo, so the Tools it installs live
# in the home directory and survive a Rebuild of a Dev container with a Home volume
# shellcheck disable=SC2154  # home_bin_dir is set by switch_rule.sh
if machine_switches; then
  mkdir -p "${home_bin_dir}"
  getRelease config set installDir "${home_bin_dir}"
  getRelease config set installCommand 'install -m 755 {source} {target}'
else
  echo "🟢 getRelease keeps its config and install directory"
fi
