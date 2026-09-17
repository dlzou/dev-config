#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
mode=${1:---build}
[[ "$mode" == --build || "$mode" == --switch ]] || {
  echo "Usage: $0 [--build|--switch] [macos|ubuntu|ubuntu-arm64]" >&2
  exit 2
}
if [[ $# -gt 2 ]]; then
  echo "Too many arguments" >&2
  exit 2
fi
case "$(uname -s):$(uname -m)" in
  Darwin:arm64) native_target=macos ;;
  Linux:x86_64) native_target=ubuntu ;;
  Linux:aarch64|Linux:arm64) native_target=ubuntu-arm64 ;;
  *) echo "Unsupported platform" >&2; exit 1 ;;
esac
target=${2:-$native_target}
case "$target" in
  macos|ubuntu|ubuntu-arm64) ;;
  *) echo "Unknown configuration: $target" >&2; exit 2 ;;
esac
if [[ "$mode" == --switch && "$target" != "$native_target" ]]; then
  echo "Activation requires the current platform: $native_target" >&2
  exit 1
fi
if [[ "$(id -u)" == 0 ]]; then
  echo "Run this script as your normal user, without sudo." >&2
  exit 1
fi
[[ "${HOME:-}" == /* ]] || { echo 'HOME must be an absolute directory.' >&2; exit 1; }
# Derive local inputs from the current account and this script's checkout.
export DEV_CONFIG_USERNAME="$(id -un)"
export DEV_CONFIG_HOME="$HOME"
export DEV_CONFIG_CHECKOUT="$repo"
if ! command -v nix >/dev/null; then
  if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # The official installer may require a new login shell before PATH is ready.
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi
command -v nix >/dev/null || {
  echo "Install Nix first: https://nixos.org/download/" >&2
  exit 1
}
# Home Manager starts additional Nix commands during bootstrap, before its
# managed nix.conf exists. Pass the feature settings through to those children.
export NIX_CONFIG="${NIX_CONFIG:-}
extra-experimental-features = nix-command flakes"

# path: includes untracked files during development without requiring git add.
nix --extra-experimental-features 'nix-command flakes' build \
  --impure --no-link "path:$repo#homeConfigurations.$target.activationPackage"
if [[ "$mode" == --switch ]]; then
  # Back up colliding files; never force overwrites. A repeated collision with
  # the same backup name fails for review rather than replacing the first backup.
  nix --extra-experimental-features 'nix-command flakes' run \
    "path:$repo#home-manager" -- switch \
    --flake "path:$repo#$target" --impure -b before-dev-config
  echo 'Applied. Follow README.md to integrate the existing shell, then open a fresh terminal.'
else
  echo "Built $target without activating it. Apply with: $0 --switch $target"
fi
