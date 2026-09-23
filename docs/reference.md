# Configuration reference

For the normal setup path and update commands, start with the [README](../README.md).

## Setup details

The setup helper detects the account, checkout path, and native profile:

| Profile | Platform |
| --- | --- |
| `macos` | Apple Silicon macOS |
| `ubuntu` | x86_64 Linux |
| `ubuntu-arm64` | ARM64 Linux |

An explicit profile can be the helper's second argument; activation must match
the current platform. HTTPS cloning is also available at
`https://github.com/dlzou/dev-config.git` if GitHub SSH access is unavailable.

For direct Home Manager flake commands, supply the same inputs the helper exports
and use `--impure`:

| Build input | Value supplied by the helper |
| --- | --- |
| `DEV_CONFIG_USERNAME` | Current account from `id -un` |
| `DEV_CONFIG_HOME` | `$HOME` |
| `DEV_CONFIG_CHECKOUT` | Absolute checkout path derived from the script location |

Home Manager manages `~/.config/nix/nix.conf` with `nix-command` and `flakes`
enabled. Merge any existing settings into `home.nix` before activation.
For a custom `XDG_CONFIG_HOME`, export it before sourcing the shell integration
and set Home Manager's `xdg.configHome` to the same directory. The default is
`~/.config`.

The helper backs up conflicting files with a `.before-dev-config` suffix.
If that backup already exists, preserve it under another name before retrying;
do not force-overwrite it. Include Neovim, Yazi, Starship, Ghostty, user Nix
settings, and affected shell files in your setup backups.

## Shell integration

Home Manager generates `~/.config/dev-config/shell.sh`; the
[one-time source block](../README.md#4-connect-the-shell) is added manually.
It loads Home Manager session variables and initializes fzf and Starship for
interactive Bash/Zsh. Keep the block last and source it only once.

| Variable set or updated | Value / behavior | Purpose |
| --- | --- | --- |
| `DEV_CONFIG_PROFILE` | Home Manager's `config.home.profileDirectory` | Locate the active personal profile and verify tool selection |
| `PATH` | Put `$DEV_CONFIG_PROFILE/bin` first outside a Nix development shell | Prefer managed personal tools |
| `EDITOR`, `VISUAL` | `nvim` | Default editor for CLI applications |
| `FZF_DEFAULT_OPTS` | `--height 40% --layout=reverse` | Shared picker defaults from `programs.fzf.defaultOptions` |
| `TERMINFO_DIRS` (Linux) | Prepend profile `share/terminfo`, `/etc/terminfo`, `/lib/terminfo`, `/usr/share/terminfo`; retain existing entries | Let Nix terminal tools find system terminal definitions |

`IN_NIX_SHELL` is an input, not set here: a nonempty value skips the PATH prepend
so the project shell's tools stay first. `TERMINFO` is left unchanged.
`XDG_CONFIG_HOME` selects the source-block location as described in
[setup details](#setup-details).

Old integrations to replace include `~/.fzf.zsh`, apt fzf scripts under
`/usr/share`, and separate `starship init` calls. On Ubuntu, follow the
[Bash ordering guide](ubuntu-validation.md#bash-startup-order).

## Application configuration

Select a Nerd Font in your terminal for Starship symbols and Neovim icons.
An existing `STARSHIP_CONFIG` override must point to the managed file (normally
`~/.config/starship.toml`) or be removed for it to take effect.

### Ghostty

Install Ghostty separately through your application/package manager. Home Manager
creates `~/.config/ghostty/config.ghostty`, which requires Ghostty 1.2.3+.
It includes [shared settings](../ghostty/config.ghostty) first, then
[macOS](../ghostty/macos.ghostty) or [Ubuntu](../ghostty/ubuntu.ghostty) overrides.
See those files for platform-specific navigation bindings.

Reload with **Cmd-Shift-,** on macOS or **Ctrl-Shift-,** on Linux; some settings
require a new terminal or restart. Validate with `ghostty +validate-config`.
On macOS, if the CLI is not on PATH, use
`/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config`.

Files under `~/Library/Application Support/com.mitchellh.ghostty/` load after the
XDG configuration and can override it. See [Ghostty configuration](https://ghostty.org/docs/config)
if edits appear to have no effect.

### Yazi file openers

The rules in [yazi.toml](../yazi/yazi.toml) provide these choices:

| File type | Default in standalone Yazi | Other choices with Shift-O |
| --- | --- | --- |
| HTML / HTM, SVG | System default application | Editor, Reveal |
| CSV / TSV | Editor | System default application, Reveal |

The system opener uses `open` on macOS or `xdg-open` on an Ubuntu desktop and
follows OS file associations. Yazi's editor choice uses `$EDITOR`; other file
types retain its defaults. A custom `YAZI_CONFIG_HOME` must point to the managed
configuration directory (normally `~/.config/yazi`).

In Neovim's chooser, Enter selects a file for Neovim; Shift-O offers external
openers. Over SSH, openers run remotely. To view remote HTML locally, transfer the
files or serve them through an SSH port forward.

## Development tools

[Nix packages](../nix/packages.nix) supply personal executables; lazy.nvim manages
Neovim plugins. Minimum versions are Neovim 0.12.0, tree-sitter CLI 0.26.1, and
Ruff 0.5.3. See the [Neovim guide](../nvim/README.md#first-launch-and-updates) for
initial plugin/parser installation and health checks.

### Compilers and project environments

Ordinary shells and Neovim native builds use the system C/C++ compiler. Check
`cc --version` and `c++ --version`; see [prerequisites](../README.md#2-install-prerequisites)
if missing. Preserve project-specific `CC`/`CXX` settings. Nix-installed clangd
provides editor support independently of the project's compiler.

For an optional environment with the shared tools **and a Nix C/C++ compiler**,
run from the checkout:

```sh
nix develop "path:$PWD"
```

Keep project-specific native libraries/toolchains in their own development
environments. System packages, drivers, CUDA, Docker, system Python, and vendor
utilities retain their existing management. Git identity, Conda, credentials,
and work initialization stay local; Homebrew can coexist for Mac apps and exceptions.

### Python projects

Nix supplies uv and the editor/language servers; uv manages project interpreters
and dependencies:

```sh
cd /path/to/python-project
uv sync
uv run python main.py
uv run pytest  # when pytest is declared by the project
uv run nvim .
```

Launch Neovim in the project's environment or configure basedpyright's interpreter
explicitly; see [language support](../nvim/README.md#language-support).

## Troubleshooting

| Symptom | Check / action |
| --- | --- |
| Unexpected executable version | Run `type -a <command>` in a fresh terminal; check the source block runs last and review Ubuntu login ordering |
| Ordinary shell selects a Nix compiler | Check for an older active profile or another Nix installation on PATH; apply the current profile and verify again |
| Verification cannot find the configured profile | Activate, then open a terminal that sources the integration |
| Activation cannot find a checkout file | Run the helper from the complete checkout at its current location |
| A file or backup blocks activation | Preserve it before retrying; see [backup handling](#setup-details) |

### Ghostty terminfo over SSH

For `missing or unsuitable terminal: xterm-ghostty` on Ubuntu, check
`infocmp xterm-ghostty` and `echo "$TERMINFO_DIRS"` on the remote machine.
Apply the shell integration and open a fresh shell. If the definition is missing,
follow [Ghostty's terminfo guidance](https://ghostty.org/docs/help/terminfo).

An existing tmux server may retain an older environment. Compare with
`tmux -L terminfo-check -f /dev/null new-session` and exit the test session afterward.
Finish existing sessions before restarting their server.

## Recovery

Run `home-manager generations`, then the selected generation's `activate` script.
This restores managed packages and generated files. Use Git/backups for edits to
the writable checkout and manual shell files. Older generations retain their
original checkout paths; after relocation, rebuild the desired Git revision at
the current location instead of activating a generation pointing to a missing path.

Keep previous installations until validation succeeds on each machine. To use
retained Homebrew/apt tools, restore the backed-up shell setup or use absolute
executable paths; verify with `type -a`. Uninstallation is separate from the
setup helper; do not delete `/nix` as a shortcut.
