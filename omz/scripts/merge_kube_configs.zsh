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

# Merge into a temp file first. Redirecting straight at $output_file truncates
# it before kubectl runs, so any kubectl failure would leave the live config
# empty; set -e cannot help, because the truncation is the shell's, not kubectl's.
tmp_file="$(mktemp "${output_file}.XXXXXX")"
trap 'rm -f -- "$tmp_file"' EXIT INT TERM

if ! KUBECONFIG="$kubeconfig" kubectl config view --flatten > "$tmp_file"; then
  echo "Failed to merge kubeconfigs; $output_file left unchanged" >&2
  exit 1
fi

# Written before the move so the file is never briefly world-readable in place
chmod 600 "$tmp_file"
mv -- "$tmp_file" "$output_file"
echo "Merged kubeconfig written to $output_file"
