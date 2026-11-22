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
