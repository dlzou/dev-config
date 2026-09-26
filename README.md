# Personal development configuration

Personal CLI tools and app settings for Apple Silicon macOS and Ubuntu (x86_64
or ARM64), installed with Nix and Home Manager. Shell startup files and work-tool
setup stay locally managed.

## Install

### 1. Clone the repository

Choose any checkout location; these examples use `~/dev-config`:

```sh
git clone git@github.com:dlzou/dev-config.git ~/dev-config
cd ~/dev-config
```

### 2. Install prerequisites

If Nix is missing, use the [official installer](https://nixos.org/download/):

```sh
curl --fail --location https://nixos.org/nix/install -o /tmp/install-nix
sudo sh /tmp/install-nix --daemon
```

Open a new terminal afterward. Neovim plugin builds also need a system compiler:

| Platform | Install if missing |
| --- | --- |
| macOS | `xcode-select --install` |
| Ubuntu | `sudo apt install build-essential` |

### 3. Activate

Back up existing app configurations and shell startup files outside the checkout;
move an existing `~/.config/nvim` directory aside. Review
[setup details](docs/reference.md#setup-details) for existing Nix settings,
custom XDG paths, or backup collisions.

From the checkout, as your normal user:

```sh
./scripts/setup-home.sh --switch
```

### 4. Connect the shell

Add this once at the **end** of `~/.zshrc` (Zsh) or `~/.bashrc` (Bash):

```sh
if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/dev-config/shell.sh" ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}/dev-config/shell.sh"
fi
```

Replace old fzf/Starship initialization with this block. Transfer custom fzf
options to `home.nix` before removing old exports. On Ubuntu, check
[Bash startup ordering](docs/ubuntu-validation.md#bash-startup-order).

Open a fresh terminal and verify:

```sh
~/dev-config/scripts/verify-tools.sh
```

## Everyday commands

Run these from the checkout. Installed tools work directly in your terminal.

| Command | Purpose |
| --- | --- |
| `./scripts/setup-home.sh --switch` | Build and apply configuration changes |
| `./scripts/setup-home.sh --build` | Optional build check without activation |
| `./scripts/verify-tools.sh` | Check executable selection and dependencies |
| `home-manager generations` | List configurations available for [recovery](docs/reference.md#recovery) |

Build and switch use the existing lockfile; they do not upgrade dependencies.

## Editing configuration

| Configuration | Source | Apply edits |
| --- | --- | --- |
| Packages | `nix/packages.nix` | Run `--switch` |
| Links, fzf options, shell integration | `home.nix` | Run `--switch`; open a fresh terminal for shell changes |
| Platforms and pinned Nix inputs | `flake.nix`, `flake.lock` | Run `--switch` |
| Neovim and pinned plugins | `nvim/` | Restart Neovim; see the [editor guide](nvim/README.md) |
| Starship prompt | `starship.toml` | Next prompt render |
| Tmux controls and clipboard | `tmux/tmux.conf` | See [tmux reload instructions](docs/reference.md#tmux-and-clipboard) |
| Yazi openers | `yazi/yazi.toml` | Restart Yazi |
| Ghostty shared/platform settings | `ghostty/*.ghostty` | Reload Ghostty configuration |

Neovim, Starship, Yazi, and tmux link directly to this writable checkout; Ghostty loads
its settings from it. Edit generated configuration through `home.nix`.
After moving the checkout, run `./scripts/setup-home.sh --switch` from its new
location to refresh links and include paths.

## Updates

To update Nixpkgs and Home Manager, run from the checkout:

```sh
nix flake update
git diff -- flake.lock
./scripts/setup-home.sh --switch
```

Use `nix flake update nixpkgs` to update only packages. Keep the reviewed lockfile
in Git and leave `home.stateVersion` unchanged; it controls compatibility defaults.
For Neovim plugins and parsers, see [First launch and updates](nvim/README.md#first-launch-and-updates).

## Guides and workflows

- [Reference](docs/reference.md): shell variables, app configuration, development tools, troubleshooting, and recovery.
- [Neovim guide](nvim/README.md): first launch, shortcuts, and language support.
- [Ubuntu checklist](docs/ubuntu-validation.md) and [validation status](docs/rollout-status.md).
- Repository skills: [$setup-dev-config](.agents/skills/setup-dev-config/SKILL.md) for machine setup;
  [$manage-dev-tools](.agents/skills/manage-dev-tools/SKILL.md) for adding, removing, or updating tools.
