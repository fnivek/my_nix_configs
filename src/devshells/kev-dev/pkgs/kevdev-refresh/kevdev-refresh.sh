# Intentionally no shebang: nix will add one via writeShellScriptBin
set -euo pipefail

usage() {
  cat <<'EOF'
kevdev-refresh — refresh the remote flake github:fnivek/kev_dev and reload direnv

Usage:
  kevdev-refresh            Refresh lock for github:fnivek/kev_dev, then run `direnv reload`.
  kevdev-refresh -h|--help  Show this help.

What it runs:
  nix flake metadata github:fnivek/kev_dev --refresh > /dev/null && direnv reload

Requirements:
  - nix and direnv available on PATH (direnv is included in this dev shell).
EOF
}

case "${1-}" in
  -h|--help)
    usage
    exit 0
    ;;
  "" )
    ;;
  * )
    echo "kevdev-refresh: unknown option: $1" >&2
    usage
    exit 2
    ;;
esac

if ! command -v nix > /dev/null 2>&1; then
  echo "kevdev-refresh: 'nix' not found on PATH" >&2
  exit 127
fi
if ! command -v direnv > /dev/null 2>&1; then
  echo "kevdev-refresh: 'direnv' not found on PATH" >&2
  exit 127
fi

nix flake metadata github:fnivek/kev_dev --refresh > /dev/null
direnv reload
