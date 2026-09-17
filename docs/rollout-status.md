# Validation status

Last reviewed: 2026-09-17. These are observed results for the current setup, not a
guarantee for later dependency updates.

| Platform | Configuration evaluation | Build and activation | Runtime checks |
| --- | --- | --- | --- |
| Apple Silicon macOS | Passed | Passed | Checks below passed |
| x86_64 Ubuntu | Passed | Pending | Pending |
| ARM64 Ubuntu | Passed | Pending | Pending |

## Passed checks

- All three Home Manager profiles evaluate; flake checks pass for all declared
  package and development-shell outputs.
- Mac build, activation, repeat activation, and activation after checkout
  relocation passed. Fresh shells select the expected Nix executables.
- fzf bindings/default options and Starship prompt hooks work. Starship renders
  from the writable TOML link; Ghostty's linked configuration validates.
- Neovim starts and its dependency health check passes. Python attaches basedpyright
  and Ruff; C++ attaches clangd. Manual Ruff formatting works without format-on-save.
- Telescope opens and its native sorter builds/loads. A Python Treesitter parser
  builds/loads, and Yazi opens/closes through the Neovim integration.
- An isolated tmux session works. A C++ sample compiles/runs. A temporary uv project
  passes a unittest using an existing Python interpreter.
- Alternate usernames, checkout paths, and XDG paths were evaluated. Paths with
  spaces and Bash/Zsh integration were checked; a project shell's PATH is preserved.
- Shell syntax, local documentation links, ignore rules, and Git whitespace checks
  pass.

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

Mac migration backups are stored under `~/.local/state/dev-config/backups/`.
See [recovery instructions](../README.md#troubleshooting-and-recovery).
