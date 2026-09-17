#!/usr/bin/env bash
set -euo pipefail

if [[ "${DEV_CONFIG_PROFILE:-}" != /* ]]; then
  echo 'Missing configured Nix profile. Activate the configuration, then open a fresh terminal with the dev-config shell integration loaded.' >&2
  exit 1
fi

failed=0
for tool in nvim basedpyright basedpyright-langserver ruff clangd tree-sitter \
  yazi ya rg fd fzf jq tmux starship uv git file make cc curl tar gzip unzip; do
  if selected=$(command -v "$tool"); then
    printf '%-24s %s\n' "$tool" "$selected"
    case "$selected" in
      "$DEV_CONFIG_PROFILE/bin/"*|/nix/store/*) ;;
      *) printf '  WARNING: selected outside the Nix profile; review PATH.\n' >&2; failed=1 ;;
    esac
  else
    printf 'MISSING: %s\n' "$tool" >&2
    failed=1
  fi
done
for tool in nvim ruff tree-sitter uv fzf; do
  if command -v "$tool" >/dev/null; then
    "$tool" --version
  fi
done
exit "$failed"
