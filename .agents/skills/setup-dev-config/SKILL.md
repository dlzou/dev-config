---
name: setup-dev-config
description: Bootstrap or migrate this dev-config checkout on Apple Silicon macOS or Ubuntu, using Nix and Home Manager while preserving local shell and work configuration. Use for first-time machine setup or completing a partial rollout.
---

# Set up dev-config

## Read the current implementation

Resolve the repository root relative to this skill (`../../..`), not from a fixed
username or checkout path. Read [README.md](../../../README.md),
[scripts/setup-home.sh](../../../scripts/setup-home.sh), and
[home.nix](../../../home.nix). For Ubuntu, also use
[docs/ubuntu-validation.md](../../../docs/ubuntu-validation.md).
Use these maintained instructions and scripts rather than creating another installer.

## Prepare the machine

- Check OS/architecture, Nix availability, existing Home Manager ownership, and
  executable selection. The current profiles support Apple Silicon macOS and
  x86_64/ARM64 Linux; do not substitute a mismatched profile.
- Inspect relevant Bash/Zsh initialization selectively. Preserve aliases, Conda,
  SSH/proxy/certificate setup, credentials, and work-tool initialization. Avoid
  printing whole startup files or putting private backups in the repository.
- Back up files affected by activation or shell edits outside the checkout.
  Inspect existing Neovim, Starship, Ghostty, and user Nix configurations. Preserve
  existing settings before merging or moving them; move a real Neovim directory
  aside before linking. Preserve any existing `.before-dev-config` backups under
  distinct names if they would block activation.
- Keep Homebrew/apt/manual tools during validation. System packages, drivers,
  CUDA, Docker, system Python, and vendor tooling retain their existing ownership.

## Build and activate

Follow the requested scope: an inventory or build-only request does not authorize
installation or activation. A request to perform setup includes the normal setup
steps; do not add another approval checkpoint for each step.

1. If Nix is missing, follow the README's official installer instructions. If Nix
   already exists, check its initialization before attempting another installation.
   The installer uses elevated privileges; the Home Manager helper runs as the
   normal user. If an installer requires interactive authentication, let the user
   complete that step and verify the result before continuing.
2. Run `./scripts/setup-home.sh --build` from the repository root. Resolve build
   failures before running `./scripts/setup-home.sh --switch`. The helper derives
   the account, checkout path, and native profile; keep the existing lockfile.
3. Follow the README's shell integration section. Source the generated
   `dev-config/shell.sh` once at the end of the interactive startup file, transfer
   shared fzf options to `home.nix`, and remove superseded fzf/Starship hooks.
   Account for custom XDG paths. Do not edit the generated file or transfer shell
   file ownership to Home Manager.
4. Verify tools in a fresh interactive terminal outside a project Nix shell using
   `./scripts/verify-tools.sh` and `type -a` for migrated commands. Investigate
   aliases and earlier PATH entries if old binaries still win. Agent-injected
   PATH entries may differ from the user's ordinary terminal.

## Validate and report

Use the checks in [docs/rollout-status.md](../../../docs/rollout-status.md) and the
Ubuntu checklist as applicable: fzf shortcuts, Starship, tmux, a representative uv
project, and Neovim health, language servers, Telescope, Yazi, and native builds.
Allow lazy.nvim and Treesitter to finish their first installation. Confirm that a
repeat activation succeeds and shell hooks are not duplicated.

Report what changed, backup locations, checks actually completed, and any pending
interactive or other-platform checks. Evaluation on macOS is not Linux runtime
validation. Explain recovery through Home Manager generations for managed outputs
and Git/backups for writable checkout files and local shell changes. Leave old
installation removal, commits, and pushes to their own user-authorized scope.
