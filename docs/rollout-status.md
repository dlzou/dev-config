# Validation status

Last reviewed: 2026-09-18. These are observed results, not a guarantee for later
dependency updates. The compiler split is activated and verified on macOS;
Ubuntu runtime validation remains pending. The newer Ghostty platform-file change
is built and checked but not yet activated.

| Platform | Configuration evaluation | Build and activation | Runtime checks |
| --- | --- | --- | --- |
| Apple Silicon macOS | Passed | Build, activation, and repeat activation passed | Compiler, fresh Zsh, and editor checks passed |
| x86_64 Ubuntu | Passed | Pending | Pending |
| ARM64 Ubuntu | Passed | Pending | Pending |

## Ghostty platform configuration (2026-09-18)

- The macOS Home Manager profile builds; all three profiles evaluate and select
  the expected shared and platform files. Package and plugin locks are unchanged.
- The macOS Ghostty CLI validates the generated configs. Isolated config checks
  confirm the shared theme, Ubuntu Ctrl-Shift-Arrow split navigation, removal of
  Ctrl-Alt-Arrow bindings, and unchanged macOS bindings.
- Activation of the generated entry file and actual Ubuntu keyboard interaction
  remain pending. CLI checks on macOS do not validate Linux desktop shortcuts.

## Compiler split validation (2026-09-18)

- All three Home Manager profiles and development shells evaluate. The compiler
  split leaves package/plugin locks unchanged; the separate theme change replaces
  Monokai with TokyoNight in the plugin lock. The macOS profile builds and exposes
  no `cc`, `c++`, `clang`, `clang++`, `gcc`, or `g++` executables.
- With the built profile and system directories on PATH, verification passes and
  Apple Clang 21.0.0 compiles/runs C and C++ samples. Temporary copies of the locked
  Telescope native sorter and a fresh Python Treesitter parser build, load, and
  perform a fuzzy match / syntax parse in Neovim.
- The optional macOS `nix develop` shell selects Nix Clang 21.1.8 and compiles/runs
  both samples. It required downloading development outputs from the binary cache;
  the initial offline attempt lacked those outputs and failed fetching a source.
- Verifier fixtures cover missing/shadowed tools, missing/failing compilers,
  compiler symlinks into the Nix store, development-shell selection, and reported
  `CC`/`CXX` overrides. Health checks cover present dependencies and missing
  compilers with macOS/Ubuntu-specific guidance.
- Activation and repeat activation pass. Fresh interactive login Zsh and a
  non-login Zsh inheriting its login environment pass the tool verifier, select
  `/usr/bin/cc` and `/usr/bin/c++`, and compile/run C and C++ samples. fzf bindings
  and options load, and Starship has one prompt hook per shell.
- Neovim dependency health, TokyoNight/Lualine, and plugin integration checks pass
  after activation. Neovim, Starship, and Ghostty still link to the checkout.
- Shell syntax, documentation links, repository-skill validation, and Git
  whitespace checks pass. No local shell edits or active native plugin artifact
  replacement was needed.

## Earlier applied-profile checks

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
