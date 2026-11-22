# shellcheck shell=bash
# Shared helpers for the i3 scripts' tests, sourced by each tests/*.sh.
# Tests wait on state (a socket, a window in the history) instead of fixed sleeps, so a slow machine is slower,
# not flaky.

# wait_for <seconds> <command...>: reruns the command every 0.1 s until it succeeds. Fails after <seconds>.
wait_for() {
  local deadline=$((SECONDS + $1))
  shift
  until "$@" >/dev/null 2>&1; do
    [ "$SECONDS" -lt "$deadline" ] || return 1
    sleep 0.1
  done
}

# start_i3 <dir>: starts i3 with an empty config and returns once it answers.
start_i3() {
  echo "# empty config" >"$1/i3.conf"
  i3 -c "$1/i3.conf" >/dev/null 2>&1 &
  wait_for 10 i3-msg -t get_version || {
    echo "FAIL: i3 did not start"
    exit 1
  }
}

stop_i3() {
  timeout 3 i3-msg exit >/dev/null 2>&1 || true
}
