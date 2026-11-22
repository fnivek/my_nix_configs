#!/usr/bin/env bash
# Regression tests for the workspace command, against a real i3 in a virtual X display.
#
# usage: xvfb-run -a tests/workspace.sh <i3-scripts package>
# needs on PATH: i3, i3-msg. `task test-i3` provides them.
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "$0")/lib.sh"

package=$1
fake_home=$(mktemp -d)

cleanup() {
  stop_i3
  rm -rf "$fake_home"
}
trap cleanup EXIT

# i3 starts on its default workspace "1", which belongs to no workspace set.
start_i3_with_two_workspace_sets() {
  mkdir -p "$fake_home/.config/i3/resources"
  printf 'main\nweb\n' >"$fake_home/.config/i3/resources/workspaces.txt"
  start_i3 "$fake_home"
}

# next and prev crashed with ValueError on a name that is not "<sort>:<num>:<set>".
check_next_and_prev_on_plain_workspace() {
  for direction in next prev; do
    if ! HOME=$fake_home timeout 10 "$package/bin/workspace" "$direction"; then
      echo "FAIL: workspace $direction on plain workspace \"1\""
      exit 1
    fi
  done
  echo "PASS: next and prev work on a plain workspace"
}

start_i3_with_two_workspace_sets
check_next_and_prev_on_plain_workspace
