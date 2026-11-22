"""Unit tests for the focus history server. The package build runs them (unittestCheckHook)."""

import threading
import unittest
from unittest import mock

from i3_focus.history_server import FocusWatcher


def watcher_with_closed_windows(window_ids):
    """A FocusWatcher whose history holds windows that i3 no longer has."""
    watcher = FocusWatcher.__new__(FocusWatcher)  # skips __init__: no i3 connection, no socket
    watcher.i3 = mock.Mock()
    watcher.i3.get_tree.return_value.find_by_id.return_value = None
    watcher.window_list = list(window_ids)
    watcher.window_list_lock = threading.RLock()
    watcher._current_window_in_history = 0
    return watcher


class JumpToClosedWindow(unittest.TestCase):
    """A window can close after the history recorded it and before its close event is handled."""

    def test_last_skips_a_closed_window(self):
        watcher_with_closed_windows([1, 2]).last()

    def test_next_skips_a_closed_window(self):
        watcher_with_closed_windows([1, 2]).next()
