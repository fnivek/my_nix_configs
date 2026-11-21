#!/usr/bin/env bash
# Regression tests for the focus scripts (history server, focus_window), against a real i3 in a virtual X display.
#
# usage: xvfb-run -a tests/focus.sh <i3-scripts package>
# needs on PATH: i3, i3-msg, xterm. `task test-i3` provides all of them.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

package=$1
work=$(mktemp -d)
socket="$work/history.socket"
server_log="$work/server.log"
windows=()

cleanup() {
  kill "${windows[@]}" "${server:-}" 2>/dev/null || true
  stop_i3
  rm -rf "$work"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $1"
  echo "--- server log"
  cat "$server_log"
  exit 1
}

# Opens a window titled $1 that stays until cleanup. Its pid is in $last_window.
open_window() {
  xterm -T "$1" -e sleep 600 &
  last_window=$!
  windows+=("$last_window")
}

# Prints the history as focus_window shows it, one "App: title" line per window. A stand-in menu records what
# focus_window offers and picks the first line. Fails if focus_window fails.
history_titles() {
  rm -f "$work/menu-input"
  timeout 10 "$package/bin/focus_window" --socket-file "$socket" --menu "$work/record-menu" >/dev/null 2>&1 || return 1
  cat "$work/menu-input"
}

history_has_title() { history_titles | grep -q ": $1\$"; }

start_server() {
  printf '#!/usr/bin/env bash\ntee "%s" | head -n 1\n' "$work/menu-input" >"$work/record-menu"
  chmod +x "$work/record-menu"
  "$package/bin/focus_history_server" --socket-file "$socket" >"$server_log" 2>&1 &
  server=$!
  wait_for 10 test -S "$socket" || fail "history server did not open its socket"
  # It subscribes to i3 just after opening the socket: open windows until one is recorded.
  for i in $(seq 10); do
    open_window "ready-$i"
    if wait_for 3 history_has_title "ready-$i"; then return; fi
  done
  fail "history server never recorded a focus"
}

# Windows that close right after taking focus used to kill the server's i3 thread, so it stopped recording focus.
check_survives_windows_that_close_at_once() {
  local quick=()
  for _ in $(seq 40); do
    xterm -e true &
    quick+=($!)
  done
  wait "${quick[@]}" 2>/dev/null || true
  open_window "survivor"
  wait_for 10 history_has_title "survivor" || fail "history stopped recording focus after windows closed at once"
  echo "PASS: survives windows that close at once"
}

start_i3 "$work"
start_server
check_survives_windows_that_close_at_once
