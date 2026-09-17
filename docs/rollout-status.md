# Validation status

Last reviewed: 2026-09-17. These are observed results for the current setup, not a
guarantee for later dependency updates.

| Platform | Configuration evaluation | Build and activation | Runtime checks |
| --- | --- | --- | --- |
| Apple Silicon macOS | Passed | Passed | Checks below passed |
| x86_64 Ubuntu | Passed | Pending | Pending |
| ARM64 Ubuntu | Passed | Pending | Pending |

## Current setup

- The active Mac checkout is `~/dev-config`. Neovim, Starship, and Ghostty use writable
  Home Manager links into that checkout. Moving it requires another `--switch`.
- Home Manager manages packages, selected config links, fzf options, and generated
  shell integration. Bash/Zsh startup files, Conda, credentials, and work tools
  remain locally managed.
- Nixpkgs/Home Manager inputs are pinned in `flake.lock`; plugins are pinned in
  `nvim/lazy-lock.json`. The configuration does not install Mason or enable Linux
  GPU integration. Legacy package installations have not been removed.

## Passed checks

- All three Home Manager profiles evaluate; flake checks pass for all declared
  package and development-shell outputs.
- Mac build, activation, repeat activation, and activation after checkout
  relocation passed. Fresh shells select the expected Nix executables.
- fzf bindings/default options and Starship prompt hooks work. Starship renders
  from the writable TOML link, with the original settings preserved.
- Ghostty configuration validates and resolves to the writable checkout link.
  Effective settings are unchanged; the original config is backed up with
  `.before-dev-config`. Ghostty itself remains separately installed.
- Neovim starts and its dependency health check passes. Python attaches basedpyright
  and Ruff; C++ attaches clangd. Manual Ruff formatting works without format-on-save.
- Telescope opens and its native sorter builds/loads. A Python Treesitter parser
  builds/loads, and Yazi opens/closes through the Neovim integration.
- An isolated tmux session works. A C++ sample compiles/runs. A temporary uv project
  passes a unittest using an existing Python interpreter.
- Alternate usernames, checkout paths, and XDG paths were evaluated. Paths with
  spaces and Bash/Zsh integration were checked; a project shell's PATH is preserved.
- Shell syntax, local documentation links, ignore rules, and Git whitespace checks
  pass. The moved Neovim files preserve the prior code except updated health hints.

## Remaining coverage

- Real Ubuntu builds, activation, Bash integration, editor behavior, and work-tool
  compatibility still need testing. Follow the [Ubuntu guide](ubuntu-validation.md).
- The uv smoke test did not exercise an existing work project or its dependencies.
- Restoring a distinct earlier Home Manager generation has not been exercised.
  An isolated check confirmed that the preserved original shell setup selects the
  retained Homebrew tools.
- Intermittent roughly one-second Neovim startup delays reported in Ghostty have
  not been reproduced reliably. Controlled warm-start measurements do not rule
  them out. The [editor guide](../nvim/README.md#startup-timing) explains capture.

Private shell/config backups remain outside this repository under
`~/.local/state/dev-config/backups/`; Home Manager also preserves displaced files
with `.before-dev-config`. Do not include backup contents in Git.
