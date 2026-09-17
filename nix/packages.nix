{ pkgs }:
assert pkgs.lib.versionAtLeast pkgs.neovim.version "0.12.0";
assert pkgs.lib.versionAtLeast pkgs.tree-sitter.version "0.26.1";
assert pkgs.lib.versionAtLeast pkgs.ruff.version "0.5.3";
with pkgs; [
  neovim basedpyright ruff clang-tools tree-sitter yazi
  ripgrep fd fzf jq tmux starship uv
  git file gnumake stdenv.cc curl gnutar gzip unzip
]
