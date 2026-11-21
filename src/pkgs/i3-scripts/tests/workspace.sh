#!/usr/bin/env bash
# Regression tests for the workspace command, run against a real i3 in a virtual X display.
#
# usage: xvfb-run -a tests/workspace.sh <i3-scripts package>
# needs on PATH: i3, i3-msg. `task test-i3` provides them.
set -euo pipefail

package=$1
home=$(mktemp -d)

cleanup() {
  timeout 3 i3-msg exit >/dev/null 2>&1 || true
  rm -rf "$home"
}
trap cleanup EXIT

# i3 starts on its default workspace "1", which belongs to no workspace set.
start_i3_with_two_workspace_sets() {
  mkdir -p "$home/.config/i3/resources"
  printf 'main\nweb\n' >"$home/.config/i3/resources/workspaces.txt"
  echo "# empty config" >"$home/i3.conf"
  i3 -c "$home/i3.conf" >/dev/null 2>&1 &
  sleep 2
}

# next and prev used to crash on a name that is not "<sort>:<num>:<set>".
check_next_and_prev_on_plain_workspace() {
  for direction in next prev; do
    if ! HOME=$home timeout 10 "$package/bin/workspace" "$direction"; then
      echo "FAIL: workspace $direction on plain workspace \"1\""
      exit 1
    fi
  done
  echo "PASS: next and prev work on a plain workspace"
}

start_i3_with_two_workspace_sets
check_next_and_prev_on_plain_workspace
