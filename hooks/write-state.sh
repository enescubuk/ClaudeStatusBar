#!/bin/sh

set -eu

status="${1:-}"
case "$status" in
  working|done|question) ;;
  *)
    echo "Usage: $0 working|done|question" >&2
    exit 1
    ;;
esac

state_dir="$HOME/.claude/statusbar"
state_file="$state_dir/state.json"
temp_file="$state_dir/state.json.$$"

mkdir -p "$state_dir"
printf '{"status":"%s"}\n' "$status" > "$temp_file"
mv "$temp_file" "$state_file"
