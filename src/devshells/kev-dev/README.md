# Kev Dev
This is my development environment that I like to use, but is not project specific.
So it mostly contains my current favorite modal editor, helix, and supporting programs.

## How it works
We use a combination of nix flake dev shells and [direnv](https://direnv.net/)to automatically enable a fully deterministic dev environment.
I followed [Effortless dev environments with Nix and direnv](https://determinate.systems/posts/nix-direnv/).
In additon I use [nix-direnv](https://github.com/nix-community/nix-direnv) an extension of direnv to improve performance with nix flakes.
When you cd into the directory it automatically activates the deterministic environment.

## Environment
### Helix - modal editor
Using the most up to date version in flakehub unstable nixpkgs.
Languages servers are installed for:
* yaml
* toml
* json
* nix
* bash

### go-task - replacement for make
I use task across most projects so I include the latest version globaly.
