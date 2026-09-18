#!/usr/bin/env bash
set -euo pipefail

if [[ "${DEV_CONFIG_PROFILE:-}" != /* ]]; then
  echo 'Missing configured Nix profile. Activate the configuration, then open a fresh terminal with the dev-config shell integration loaded.' >&2
  exit 1
fi

failed=0
for tool in nvim basedpyright basedpyright-langserver ruff clangd tree-sitter \
  yazi ya rg fd fzf jq tmux starship uv git file make curl tar gzip unzip; do
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
# Follow compiler symlinks, including those reached through ~/.nix-profile or ~/bin.
# readlink -f is not available on every supported macOS installation.
resolve_executable() {
  local target=$1 link
  while [[ -L "$target" ]]; do
    link=$(readlink "$target") || return 1
    case "$link" in
      /*) target=$link ;;
      *) target=${target%/*}/$link ;;
    esac
  done
  (cd -P -- "${target%/*}" && printf '%s/%s\n' "$PWD" "${target##*/}")
}

case "$(uname -s)" in
  Darwin) compiler_setup='Install Xcode Command Line Tools with: xcode-select --install' ;;
  Linux) compiler_setup='On Ubuntu, install the system toolchain with: sudo apt install build-essential' ;;
  *) compiler_setup='Install your operating system C/C++ toolchain.' ;;
esac
for tool in cc c++; do
  if selected=$(command -v "$tool"); then
    printf '%-24s %s\n' "$tool" "$selected"
    if resolved=$(resolve_executable "$selected"); then
      if [[ -z "${IN_NIX_SHELL:-}" && "$resolved" == /nix/store/* ]]; then
        printf '  WARNING: compiler resolves to %s; ordinary shells should use the system compiler. Review PATH.\n' "$resolved" >&2
        failed=1
      fi
    else
      printf '  Cannot resolve compiler path.\n' >&2
      failed=1
    fi
    if version=$("$selected" --version 2>&1); then
      printf '  %s\n' "${version%%$'\n'*}"
    else
      printf '  Compiler could not run --version. %s\n' "$compiler_setup" >&2
      failed=1
    fi
  else
    printf 'MISSING: %s. %s\n' "$tool" "$compiler_setup" >&2
    failed=1
  fi
done
if [[ -n "${CC:-}" || -n "${CXX:-}" ]]; then
  printf 'Compiler overrides: CC=%s CXX=%s; builds may use these instead of cc/c++.\n' "${CC:-unset}" "${CXX:-unset}"
fi

for tool in nvim ruff tree-sitter uv fzf; do
  if command -v "$tool" >/dev/null; then
    "$tool" --version
  fi
done
exit "$failed"
