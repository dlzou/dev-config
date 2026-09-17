# Personal development configuration

CLI tools, Neovim, and Starship settings for Apple Silicon macOS and Ubuntu
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
| `scripts/setup-home.sh` | Build and activate the current platform's profile |
| `scripts/verify-tools.sh` | Check that the shell selects Nix-managed tools |
| `scripts/setup-macos.sh` | Optional Homebrew fallback for editor dependencies |

The profile includes Neovim, basedpyright, Ruff, clangd, tree-sitter CLI, Yazi,
ripgrep, fd, fzf, jq, tmux, Starship, and uv. Git, a compiler, Make, file, curl,
tar, gzip, and unzip support plugin/parser downloads and builds.

The package expression requires Neovim 0.12.0+, tree-sitter CLI 0.26.1+, and
Ruff 0.5.3+. Exact package sources are pinned in `flake.lock`; plugin revisions are
pinned independently in `nvim/lazy-lock.json`. Mason is not used.

## Install

### 1. Clone the repository

Choose any checkout location; these examples use `~/dev-config`:

```sh
git clone git@github.com:dlzou/nvim-config.git ~/dev-config
cd ~/dev-config
```

The setup script detects its own checkout location. No username or checkout-path
changes are needed in the Nix files. The SSH clone URL requires GitHub SSH access;
the equivalent HTTPS URL is `https://github.com/dlzou/nvim-config.git`.

Before activation, back up existing Neovim and Starship configurations and the
shell startup files you will edit. Move an existing `~/.config/nvim` directory
aside rather than replacing it in place. The setup helper backs up conflicting
files with a `.before-dev-config` suffix; an existing backup can block activation.
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
On macOS, retain Xcode Command Line Tools for existing Homebrew/work workflows.

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
the current platform. Intel macOS is not included in the flake.

The helper passes `DEV_CONFIG_USERNAME`, `DEV_CONFIG_HOME`, and
`DEV_CONFIG_CHECKOUT` to Nix and uses `--impure` to read those local values. Direct
Home Manager flake commands need the same variables and flag; prefer the helper.
Package sources remain pinned by `flake.lock`.

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

Keep aliases, Conda initialization, and work-tool setup in your existing startup
files. Home Manager does not own those files.

The integration uses Home Manager's configured profile directory and exports it
as `DEV_CONFIG_PROFILE` for verification. It places that profile's `bin` first on
PATH after other initialization, so old `~/bin` or Homebrew tools do not shadow
it. When `IN_NIX_SHELL` is set, it preserves the development shell's PATH order.
Avoid adding another PATH prepend after this block.

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

Home Manager links the Neovim directory and Starship TOML directly to the writable
checkout. Do not edit the generated `dev-config/shell.sh`; its source is `home.nix`.
An explicit `STARSHIP_CONFIG` environment variable overrides Starship's normal
config path; remove or adjust it if you want the managed file to take effect.

After moving the checkout, run `./scripts/setup-home.sh --switch` from the new
location to update both links. Until then they point to the old location. Shell
startup files continue to source the integration in the configured XDG directory.

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
configure basedpyright's interpreter explicitly. The Python remote-plugin host
is separate from Python language-server support and is disabled in this setup.

The flake also provides an optional trial shell with the shared tools:

```sh
nix develop "path:$HOME/dev-config"
```

Use separate project-specific development shells when a project needs its own
native libraries or toolchain. Automatic project activation is not configured.

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

Neovim updates are separate: `:Lazy update` updates plugins and their lockfile,
`:Lazy restore` restores pinned revisions, and `:TSUpdate` updates syntax parsers.

## Troubleshooting and recovery

- If a command selects an unexpected version, inspect `type -a <command>` in a
  fresh terminal. Check that the shell integration runs last. The verification
  script expects the personal Nix profile; project shells can intentionally
  select other tools.
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

## Homebrew fallback on macOS

```sh
~/dev-config/scripts/setup-macos.sh
```

This installs missing editor dependencies, including basedpyright, Ruff, search
tools, Yazi, and tree-sitter CLI. It requires Homebrew and Xcode Command Line Tools,
retains compatible executables already on PATH, and upgrades only when required
for compatibility. It does not install the full personal CLI profile or change
PATH. To upgrade a particular formula deliberately, use `brew upgrade <formula>`.

Without Home Manager, link `~/.config/nvim` to the checkout's `nvim/` directory
after backing up the existing configuration. Starship's link and shell integration
must also be arranged separately if desired.
