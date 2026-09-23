# Validation status

Last reviewed: 2026-09-22. These are observed results, not a guarantee for later
dependency updates. The compiler split is activated and verified on macOS;
Broader Ubuntu runtime validation remains pending. The macOS Ghostty entry file
and Yazi configuration link are present in the active Home Manager configuration.

| Platform | Configuration evaluation | Build and activation | Runtime checks |
| --- | --- | --- | --- |
| Apple Silicon macOS | Passed | Build, activation, and repeat activation passed | Compiler, fresh Zsh, and editor checks passed |
| x86_64 Ubuntu | Passed | Pending | Pending |
| ARM64 Ubuntu | Passed | Pending | Pending |

## Markview previews (2026-09-22)

- Markview is installed and pinned; no existing plugin revisions changed. LaTeX,
  HTML, and YAML parsers compile and load on macOS using the host compiler.
- Headless checks pass for raw Markdown opening at startup and later, opt-in
  preview decorations, both local shortcuts, repeated split preview, editing-mode
  callbacks, and required-parser health. Closing a split opened from raw source
  preserves that state; new Markdown buffers start raw. Code buffers retain their
  original conceal defaults and have no Markdown shortcuts.
- With raw-by-default previews, seven warm startup samples give medians of
  65.4 ms for an empty editor and 108.5 ms for a mixed Markdown/math fixture.
  Earlier measurements were 60.6 / 85.8 ms before Markview and 62.1 / 336.6 ms with
  automatic preview. Rendering now happens on request. These are headless timings,
  not Ghostty latency.
- Actual terminal font appearance and Ubuntu runtime behavior remain unverified.

## Yazi file openers (2026-09-22)

- All three Home Manager profiles evaluate; the macOS profile builds with a
  writable link to the checkout's Yazi configuration. This integration changed no
  package or plugin revisions.
- Isolated macOS Yazi checks verify HTML/HTM/SVG default dispatch with a stub
  system opener, CSV/TSV opener menus, and file selection through chooser mode.
- The active macOS configuration links to the checkout's Yazi TOML. Actual desktop
  application launches and Ubuntu runtime checks remain pending.

## Ubuntu terminfo integration (2026-09-21)

- The user confirmed Ubuntu's system `infocmp` finds `xterm-ghostty` under
  `/usr/share/terminfo`, while Nix tmux failed without an explicit path. A fresh
  tmux server worked with `TERMINFO=/usr/share/terminfo`.
- The Linux-only fix uses `home.sessionSearchVariables.TERMINFO_DIRS` to prepend
  the personal profile and system directories. All three Home Manager profiles
  evaluate and the macOS profile builds without activation.
- Generated session scripts pass Bash/Zsh syntax checks. Twelve Ubuntu export
  checks cover unset, empty, and custom search paths, retaining existing entries
  and leaving `TERMINFO` unchanged. The macOS declaration and lockfiles are unchanged.
- Documentation links and Git whitespace checks pass. The user subsequently
  confirmed plain `tmux` works on Ubuntu over SSH; broader Ubuntu checks remain
  pending.

## Ghostty platform configuration (2026-09-18)

- The macOS Home Manager profile builds; all three profiles evaluate and select
  the expected shared and platform files. Package and plugin locks are unchanged.
- The macOS Ghostty CLI validates the generated configs. Isolated config checks
  confirm the shared theme, Ubuntu Ctrl-Shift-Arrow split navigation, removal of
  Ctrl-Alt-Arrow bindings, and unchanged macOS bindings.
- The active macOS entry file includes the checkout's shared and macOS settings.
  Actual Ubuntu keyboard interaction remains pending; CLI checks on macOS do not
  validate Linux desktop shortcuts.

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
- A startup log captured a configured Neovim launch taking 794 ms, followed by
  56 ms on the next launch. Loading was slower across several components, which
  is consistent with cold caches or system contention; the cause remains
  unconfirmed. Warm benchmarks do not explain this intermittent delay. See the
  [startup profiling instructions](../nvim/README.md#startup-timing).

Mac migration backups are stored under `~/.local/state/dev-config/backups/`.
See [recovery instructions](reference.md#recovery).
