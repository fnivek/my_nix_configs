#!/usr/bin/env bash
# Regression tests for focus_history_server, run against a real i3 in a virtual X display.
#
# usage: xvfb-run -a tests/history-server.sh <i3-scripts package>
# needs on PATH: i3, i3-msg, xterm, python3. `task test-i3` provides all of them.
set -euo pipefail

package=$1
work=$(mktemp -d)
socket="$work/history.socket"
server_log="$work/server.log"
windows=()

cleanup() {
  kill "${windows[@]}" "${server:-}" 2>/dev/null || true
  timeout 3 i3-msg exit >/dev/null 2>&1 || true
  rm -rf "$work"
}
trap cleanup EXIT

start_i3_and_server() {
  echo "# empty config" >"$work/i3.conf"
  i3 -c "$work/i3.conf" >/dev/null 2>&1 &
  sleep 2
  "$package/bin/focus_history_server" --socket-file "$socket" >"$server_log" 2>&1 &
  server=$!
  sleep 2
}

# Opens a window that stays until cleanup. The shell inside may retitle it.
open_window() {
  xterm -e "printf '\033]2;%s\007' '$1'; sleep 600" &
  windows+=($!)
  sleep 0.2
}

# Prints the history the server reports, through the same client focus_window uses.
read_history_with_client() {
  PYTHONPATH=$(echo "$package"/lib/python3*/site-packages) timeout 10 python3 -c '
import sys
from i3_focus.tools import Sockets
print(len(Sockets(sys.argv[1]).get_containers_history()))' "$socket"
}

fail() {
  echo "FAIL: $1"
  echo "--- server log"
  cat "$server_log"
  exit 1
}

# Windows that close right after taking focus used to kill the server's i3 thread.
check_survives_windows_that_close_at_once() {
  local quick=()
  for _ in $(seq 40); do
    xterm -e true &
    quick+=($!)
  done
  wait "${quick[@]}" 2>/dev/null || true
  open_window "survivor"
  sleep 1
  grep -q Traceback "$server_log" && fail "server raised after windows closed at once"
  [ "$(read_history_with_client)" -ge 1 ] || fail "history stopped recording focus"
  echo "PASS: survives windows that close at once"
}

# A history over 4 KB used to be cut off by the client's single recv().
check_client_reads_history_over_4kb() {
  for i in $(seq 40); do
    open_window "a-window-title-long-enough-to-grow-the-history-past-four-kilobytes-$i"
  done
  sleep 2
  [ "$(read_history_with_client)" -ge 40 ] || fail "client did not read the whole history"
  echo "PASS: client reads a history over 4 KB"
}

start_i3_and_server
check_survives_windows_that_close_at_once
check_client_reads_history_over_4kb
