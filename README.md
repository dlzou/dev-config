# Personal development configuration

CLI tools, Neovim, Starship, and Ghostty settings for Apple Silicon macOS and Ubuntu
(x86_64 or ARM64). Nix supplies external executables; standalone Home Manager
installs the personal profile and links configuration files to this checkout.
Neovim's lazy.nvim manages plugins separately.

Bash/Zsh startup files, Git identity, Conda, credentials, and work-tool setup remain
locally managed. Homebrew can coexist for Mac apps and exceptions. Keep system
packages, drivers, CUDA, Docker, and system Python under their existing management.

See [validation status](docs/rollout-status.md) for completed checks and remaining
Ubuntu coverage, and [Neovim documentation](nvim/README.md) for editor shortcuts.

## Configuration files

| File | Purpose |
| --- | --- |
| `flake.nix` / `flake.lock` | Platform profiles and pinned Nixpkgs/Home Manager inputs |
| `home.nix` | Packages, configuration links, fzf options, and generated shell integration |
| `nix/packages.nix` | Shared external tools and minimum editor dependency versions |
| `nvim/` | Writable Lua configuration and `lazy-lock.json` |
| `starship.toml` | Writable prompt settings in native TOML |
| `ghostty/*.ghostty` | Writable shared settings and macOS/Ubuntu overrides |
| `scripts/setup-home.sh` | Build and activate the current platform's profile |
| `scripts/verify-tools.sh` | Check Nix-managed tools and the external C/C++ compiler |

The profile includes Neovim, basedpyright, Ruff, clangd, tree-sitter CLI, Yazi,
ripgrep, fd, fzf, jq, tmux, Starship, and uv. Git, Make, file, curl, tar, gzip,
and unzip support plugin/parser downloads and builds. Those builds use the system
C/C++ compiler: Ubuntu's GCC or macOS Apple Clang. Nix supplies clangd for editor
support independently of the compiler used to build a project.

The package expression requires Neovim 0.12.0+, tree-sitter CLI 0.26.1+, and
Ruff 0.5.3+. Exact package sources are pinned in `flake.lock`; plugin revisions are
pinned independently in `nvim/lazy-lock.json`.

## Repository skills

Codex workflows live in `.agents/skills/` and are available when working in this
repository:

- [setup-dev-config](.agents/skills/setup-dev-config/SKILL.md): first-time machine
  setup, migration, shell integration, and validation using the existing scripts.
- [manage-dev-tools](.agents/skills/manage-dev-tools/SKILL.md): add, remove, or
  update shared CLI tools and their configuration, checks, and documentation.

Invoke them explicitly as `$setup-dev-config` or `$manage-dev-tools`, or describe
the task for automatic selection.

## Install

### 1. Clone the repository

Choose any checkout location; these examples use `~/dev-config`:

```sh
git clone git@github.com:dlzou/dev-config.git ~/dev-config
cd ~/dev-config
```

The setup script detects its own checkout location. No username or checkout-path
changes are needed in the Nix files. The SSH clone URL requires GitHub SSH access;
the equivalent HTTPS URL is `https://github.com/dlzou/dev-config.git`.

Before activation, back up existing Neovim, Starship, Ghostty, and user Nix
configurations and the shell startup files you will edit. Keep backups outside
the repository. Move an existing `~/.config/nvim` directory aside rather than
replacing it in place. The setup helper backs up conflicting files with a
`.before-dev-config` suffix; an existing backup can block activation.
Preserve that backup under another name before retrying.

### 2. Install Nix

Use the [official multi-user installer](https://nixos.org/download/). It creates
the Nix store and daemon and may add initialization to system shell startup files.
Download it before executing it:

```sh
curl --fail --location https://nixos.org/nix/install -o /tmp/install-nix
sudo sh /tmp/install-nix --daemon
```

Use `sudo` for this system-wide installation step. Run the Home Manager helper
below as your normal user, without `sudo`. Open a new terminal after installation.
Neovim's native plugin/parser builds also require the system C/C++ toolchain:

- **Ubuntu:** retain the existing compiler; if missing, install `build-essential`
  with `sudo apt install build-essential`.
- **macOS:** retain Xcode Command Line Tools; if missing, run `xcode-select --install`.

Check `cc --version` and `c++ --version`. Preserve any project-specific compiler
requirements and review existing `CC`/`CXX` overrides rather than replacing them
globally.

### 3. Build and activate

From the checkout:

```sh
./scripts/setup-home.sh --build
./scripts/setup-home.sh --switch
```

`--build` downloads/builds the configuration without activating it. `--switch`
also builds first, then installs the personal profile and configuration links.
For routine configuration edits, running `--switch` alone is sufficient. Neither
command upgrades the locked inputs.

The helper selects the native profile automatically:

| Profile | Platform |
| --- | --- |
| `macos` | Apple Silicon macOS |
| `ubuntu` | x86_64 Linux |
| `ubuntu-arm64` | ARM64 Linux |

A profile name can be supplied as the second argument, but activation must match
the current platform.

The helper passes `DEV_CONFIG_USERNAME`, `DEV_CONFIG_HOME`, and
`DEV_CONFIG_CHECKOUT` to Nix and uses `--impure` to read those local values. Direct
Home Manager flake commands need the same variables and flag; prefer the helper.

Home Manager manages `~/.config/nix/nix.conf` to enable `nix-command` and `flakes`.
If you already have settings there, merge them into the declaration in `home.nix`
before activation. For a custom XDG directory, see the next section.

### 4. Integrate the existing shell

Add this once at the **end** of your interactive startup file (`~/.zshrc` for Zsh,
`~/.bashrc` for Bash):

```sh
if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/dev-config/shell.sh" ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}/dev-config/shell.sh"
fi
```

If you use a custom `XDG_CONFIG_HOME`, export it before this block and set
Home Manager's `xdg.configHome` to the same directory in `home.nix`. Otherwise,
both use `~/.config`.

Remove superseded fzf/Starship hooks, such as sourcing `~/.fzf.zsh`, sourcing
apt's fzf files under `/usr/share`, or calling `starship init` separately.
The generated integration loads their hooks once per shell startup. It also loads
Home Manager session variables, including fzf's `--height 40% --layout=reverse`.
Keep shared fzf options in `programs.fzf.defaultOptions` in `home.nix`; remove an
old `FZF_DEFAULT_OPTS` export after transferring any settings you want to retain.

The integration uses Home Manager's configured profile directory and exports it
as `DEV_CONFIG_PROFILE` for verification. It places that profile's `bin` first on
PATH after other initialization, so old `~/bin` or Homebrew tools do not shadow
it. When `IN_NIX_SHELL` is set, it preserves the development shell's PATH order.
Avoid adding another PATH prepend after this block. On Ubuntu, also inspect the
login startup file: `.profile` can prepend `~/bin` after sourcing `.bashrc`.
Follow the [Ubuntu Bash ordering instructions](docs/ubuntu-validation.md#bash-startup-order)
when that happens; shell files remain locally managed.

On Ubuntu, `home.sessionSearchVariables.TERMINFO_DIRS` prepends the personal
profile and system terminfo directories, retaining existing entries and leaving
`TERMINFO` unchanged. The shell integration loads these Home Manager session
variables so Nix tools such as tmux can find definitions installed by Ubuntu
packages, including Ghostty's `xterm-ghostty`.

Open a fresh terminal and run:

```sh
~/dev-config/scripts/verify-tools.sh
type -a nvim fd fzf uv clangd
```

Tools now work directly from the terminal; `nix develop` is not required for
everyday use. Select a Nerd Font in your terminal for the shared Starship symbols
and Neovim icons.

## Editing configuration

| Change | How to apply |
| --- | --- |
| Packages, fzf options, or generated shell integration | Edit the Nix files, run `--switch`, and open a fresh terminal for shell changes |
| Neovim settings | Edit `nvim/`; restart Neovim or reload the relevant Lua module |
| Starship prompt | Edit `starship.toml`; subsequent prompt renders use the changes |
| Ghostty terminal | Edit the shared or platform file in `ghostty/`; reload Ghostty configuration |

Home Manager links the Neovim directory and Starship TOML directly to the writable
checkout. Ghostty's generated entry file loads its shared and platform settings
from the checkout. Edit generated files through their source in `home.nix`.
An explicit `STARSHIP_CONFIG` environment variable overrides Starship's normal
config path; remove or adjust it if you want the managed file to take effect.

After moving the checkout, run `./scripts/setup-home.sh --switch` from the new
location to update the configuration links and Ghostty include paths. Until then
they point to the old location; the shell integration source path stays the same.

## Ghostty terminal

Install Ghostty separately through your application/package manager. Its managed
entry file is `~/.config/ghostty/config.ghostty` (or under a custom
`xdg.configHome`); this filename requires Ghostty 1.2.3 or newer. Home Manager
selects the platform file and generates two ordered `config-file` includes:

1. `ghostty/config.ghostty`: shared theme and terminal settings.
2. `ghostty/macos.ghostty` or `ghostty/ubuntu.ghostty`: platform overrides.

Both Ubuntu architectures use `ubuntu.ghostty`. On Ubuntu, **Ctrl-Shift-Arrows**
moves between splits; the former **Ctrl-Alt-Arrows** bindings are unbound. macOS
keeps its default bindings.

Run `./scripts/setup-home.sh --switch` once to install this entry file. Afterward,
edit the shared or platform file in the checkout and reload with **Cmd-Shift-,**
on macOS or **Ctrl-Shift-,** on Linux. Some settings require a new terminal or restart.
See [Editing configuration](#editing-configuration) for link and switch behavior.

On macOS, files under `~/Library/Application Support/com.mitchellh.ghostty/` load
after the XDG configuration and can override it. Keep shared settings in the
checkout; check other config files if an edit appears to have no effect. See
[Ghostty configuration](https://ghostty.org/docs/config) for file precedence and
reload behavior. Use `ghostty +validate-config` to check the effective config;
if the CLI is not on PATH on macOS, use
`/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config`.

## Neovim and Python projects

On first launch, lazy.nvim installs plugins and Treesitter installs parsers.
Wait for installation to finish, then reopen Neovim. Run `:checkhealth userconfig`
and `:checkhealth lazy`; see the [editor guide](nvim/README.md) for other checks,
shortcuts, project overrides, and manual formatting.

Use uv normally for Python projects:

```sh
cd /path/to/python-project
uv sync
uv run python main.py
uv run pytest  # when pytest is declared by the project
uv run nvim .
```

Nix supplies the editor and language-server executables; uv manages project
interpreters and dependencies. Launch Neovim in the project's environment or
configure basedpyright's interpreter explicitly.

The flake also provides an optional trial shell with the shared tools **and a Nix
C/C++ compiler**:

```sh
nix develop "path:$HOME/dev-config"
```

This changes compiler selection only inside the development shell. Ordinary
terminals and Neovim plugin builds use the system compiler after profile activation.
Use separate project-specific development shells when a project needs its own
native libraries or toolchain.

## Updates

To update Nixpkgs and Home Manager:

```sh
cd ~/dev-config
nix flake update
git diff -- flake.lock
./scripts/setup-home.sh --build
./scripts/setup-home.sh --switch
```

Use `nix flake update nixpkgs` to update only the package collection. Keep the
reviewed lockfile in Git. Leave `home.stateVersion` unchanged during routine
updates; it controls compatibility defaults, not package versions.

For Neovim plugin and parser commands, see
[First launch and updates](nvim/README.md#first-launch-and-updates).

## Troubleshooting and recovery

- If a command selects an unexpected version, inspect `type -a <command>` in a
  fresh terminal. Check that the shell integration runs last. The verification
  script expects personal tools from Nix and a working system `cc`/`c++` outside
  `nix develop`. A compiler still resolving into `/nix/store` can indicate an older
  active profile or another Nix installation on PATH; apply the updated profile
  and check again. Project shells can intentionally select other tools.
- If tmux reports `missing or unsuitable terminal: xterm-ghostty` on Ubuntu,
  check `infocmp xterm-ghostty` and `echo "$TERMINFO_DIRS"` on that machine. Apply
  the shell integration and open a fresh shell. For an existing tmux server,
  compare with `tmux -L terminfo-check -f /dev/null new-session`; exit the test
  session afterward. Existing servers may retain an earlier environment; finish
  their sessions before restarting them. If `infocmp` cannot find the definition,
  follow [Ghostty's terminfo guidance](https://ghostty.org/docs/help/terminfo).
- If `verify-tools.sh` reports a missing configured profile, activate the setup
  and open a terminal that sources the generated integration.
- If activation reports a missing checkout file, run the helper from the complete
  repository at its current location.
- If a configuration file blocks activation, preserve it and any existing
  `.before-dev-config` backup before retrying. Do not force-overwrite local files.

Use `home-manager generations` to list previous managed configurations, then run
the selected generation's `activate` script to restore it. That restores managed
packages and generated files, not edits to the writable checkout or manual shell
files. Use Git and your backups for those. Older generations retain their original
checkout paths; after a move, rebuilding the desired Git revision at the current
location is preferable to activating a generation that points to a missing path.

To select retained Homebrew/apt tools, restore the relevant shell setup from your
backup or use the executable's absolute path. Verify selection with `type -a`.
Keep old installations until validation succeeds on each machine. Package removal
and Nix uninstallation are separate from the setup helper; do not delete `/nix`
as a shortcut.
