# Kevin's I3 Scripts
I use these scripts along with I3 to make i3 behave the way I want it to.
For example the `workspace` script navigates through numbered and grouped workspaces.
Where grouped workspaces can represent a project.

## Build
Built by the repo's flake from `pyproject.toml` (see `default.nix`). From the repo root:

```
$ nix build .#i3-scripts
$ ./result/bin/workspace --help
```

## Test
`task test-i3` runs every test script in `tests/` against a real i3 in a virtual X display. Each test reproduces a fixed bug: it fails on the code before the fix and passes after. `tests/lib.sh` holds the shared helpers.
Unit tests (`tests/test_*.py`) run during the package build, so every build and CI run them.
