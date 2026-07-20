#!/usr/bin/env bash
set -euo pipefail

config_dir="${1:-$PWD}"
results_dir="${TMPDIR:-/tmp}/nvim-startup-benchmark"
mkdir -p "$results_dir"

for run in 1 2 3 4 5; do
  start_log="$results_dir/run-$run.log"
  : > "$start_log"
  nvim --headless -u "$config_dir/init.lua" -i NONE -n \
    --startuptime "$start_log" +qa
done

awk '/NVIM STARTED/ { print $1 }' "$results_dir"/run-*.log | sort -n
