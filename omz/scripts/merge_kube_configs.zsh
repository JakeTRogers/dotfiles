#!/usr/bin/env zsh
# This script merges multiple Kubernetes configuration files into a single file.

set -euo pipefail

# Define source and output
source_dir="${HOME}/.kube/configs"
output_file="${HOME}/.kube/config"

# Ensure source dir exists
if [[ ! -d "$source_dir" ]]; then
  echo "Config directory not found: $source_dir" >&2
  exit 1
fi

# Get config files
config_files=(${source_dir}/config.*(N))  # (N) = Nullglob

if (( ${#config_files[@]} == 0 )); then
  echo "No config files found in $source_dir"
  exit 1
fi

# Build colon-separated list
kubeconfig=$(IFS=:; echo "${config_files[*]}")
echo "Merging kubeconfigs: $kubeconfig"

# Merge and write output
KUBECONFIG="$kubeconfig" kubectl config view --flatten > "$output_file"
chmod 600 "$output_file"
echo "Merged kubeconfig written to $output_file"
