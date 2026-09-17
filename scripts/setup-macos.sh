#!/usr/bin/env bash
set -euo pipefail

fail() { printf '%s\n' "$*" >&2; exit 1; }
[[ "$(uname -s)" == Darwin ]] || fail 'This script is for macOS. On Linux, use scripts/setup-home.sh or the optional Nix development shell.'
command -v brew >/dev/null || fail 'Install Homebrew from https://brew.sh, then add its shellenv to your shell configuration.'
xcode-select -p >/dev/null 2>&1 || fail 'Install Xcode Command Line Tools with: xcode-select --install'
for executable in git make cc clangd curl tar file; do
  command -v "$executable" >/dev/null || fail "Missing $executable. Check Xcode Command Line Tools and PATH."
done
xcrun --find clang >/dev/null 2>&1 || fail 'Xcode Command Line Tools are unavailable. Run: xcode-select --install'

# Avoid Homebrew housekeeping or upgrades of unrelated installed dependents.
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1

compatible() {
  local executable="$1" minimum="$2" output actual
  output=$("$executable" --version 2>&1) || return 1
  [[ -z "$minimum" ]] && return 0
  [[ "$output" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]] || return 1
  actual="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
  awk -v actual="$actual" -v minimum="$minimum" 'BEGIN {
    split(actual, a, "."); split(minimum, b, ".");
    for (i = 1; i <= 3; i++) {
      if (a[i] + 0 > b[i] + 0) exit 0;
      if (a[i] + 0 < b[i] + 0) exit 1;
    }
    exit 0;
  }'
}

ensure_tool() {
  local formula="$1" executable="$2" minimum="${3:-}" brew_executable
  if command -v "$executable" >/dev/null && compatible "$executable" "$minimum"; then
    printf 'OK: %s (%s)\n' "$executable" "$(command -v "$executable")"
    return
  fi
  if brew list --versions "$formula" >/dev/null 2>&1; then
    brew_executable="$(brew --prefix "$formula")/bin/$executable"
    if [[ -x "$brew_executable" ]] && compatible "$brew_executable" "$minimum"; then
      fail "A compatible $executable is already installed at $brew_executable. Put its bin directory earlier on PATH and rerun."
    fi
    brew upgrade "$formula"
  else
    brew install "$formula"
  fi
  command -v "$executable" >/dev/null && compatible "$executable" "$minimum" \
    || fail "$executable is still missing or incompatible. Check your PATH for an older installation; required minimum: ${minimum:-a working version}."
}

ensure_tool neovim nvim 0.12.0
ensure_tool basedpyright basedpyright
ensure_tool ruff ruff 0.5.3
ensure_tool ripgrep rg
ensure_tool fd fd
ensure_tool yazi yazi
ensure_tool yazi ya
ensure_tool tree-sitter-cli tree-sitter 0.26.1
command -v basedpyright-langserver >/dev/null || fail 'basedpyright-langserver is missing; check the basedpyright installation and PATH.'
printf '\nDependencies ready. Start nvim, then run :checkhealth userconfig.\n'
