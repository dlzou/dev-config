---
name: manage-dev-tools
description: Add, remove, or update personal CLI dependencies in this dev-config repository, coordinating Nix packages, Home Manager integrations, verification, and documentation. Use for shared tool maintenance rather than project Python dependencies or Neovim-only plugin changes.
---

# Manage development tools

## Locate the declarations

Resolve the repository root relative to this skill (`../../..`). Read the relevant
current files before editing:

| File | Role |
| --- | --- |
| [nix/packages.nix](../../../nix/packages.nix) | Shared tools and minimum version assertions; used by Home Manager and the trial development shell |
| [home.nix](../../../home.nix) | Home Manager modules, links, and generated shell hooks |
| [flake.nix](../../../flake.nix) / [flake.lock](../../../flake.lock) | Supported platforms and pinned package/module sources |
| [scripts/verify-tools.sh](../../../scripts/verify-tools.sh) | Expected executable names and profile selection checks |
| [README.md](../../../README.md) | Tool ownership, application, updates, and recovery |

Check the working tree and preserve unrelated changes. Keep project Python
interpreters/dependencies under uv and Neovim plugins under lazy.nvim unless the
user explicitly requests a broader migration. Ghostty's application is installed
separately; only its configuration is managed here.

## Make the requested change

### Add a tool

- Verify the package attribute and supported platforms against the pinned Nixpkgs
  input. An upstream package or a package in newer Nixpkgs may not exist at this pin.
- Add shared executables to `nix/packages.nix`; use a small platform condition only
  when necessary. Confirm the actual binary names rather than assuming they match
  the package name (`ripgrep` provides `rg`, for example).
- Use `home.nix` when a Home Manager module or configuration integration is useful.
  Check that the module exists at the pinned Home Manager revision. Keep Bash/Zsh
  startup files locally managed and avoid duplicate initialization hooks.
- Update expected executables in `verify-tools.sh`, documentation, and any relevant
  Neovim LSP configuration or dependency health checks.

### Remove a tool

- Search for its package attribute, binaries, module settings, hooks, and consumers
  across the repository. Removing one entry from `home.packages` may leave a module
  or an interpolated store path that still installs or references the package.
  For example, fzf and Starship also have references in `home.nix`.
- Remove or adapt those integrations and verification entries as appropriate to the
  requested behavior. Check consumers before removing build/parser prerequisites.
- Removal from the active profile does not erase old generations/store paths or
  uninstall separate Brew/apt/manual copies. Garbage collection and removal of
  those installations are separate tasks, not automatic follow-up steps.

### Update versions

Keep `flake.lock` unchanged for package-list edits unless compatibility requires a
pin change. For requested upgrades, follow the README's update procedure, update
only the necessary inputs, and review the lockfile diff. Do not bump
`home.stateVersion` or update `nvim/lazy-lock.json` as part of an ordinary CLI
package change. Report when moving Nixpkgs also changes other tool versions.

## Apply and verify

1. Inspect the diff and run `git diff --check`. Validate changed scripts if any.
2. Run `./scripts/setup-home.sh --build`. For portable package changes, evaluate
   the affected platform profiles when tooling permits; distinguish evaluation
   from a successful native build. Direct flake evaluation needs the local
   `DEV_CONFIG_*` variables and `--impure` described in the README.
3. If the request includes local installation/application, run
   `./scripts/setup-home.sh --switch`; a configuration-only request stops at the
   build. Do not introduce an extra approval step when activation is already
   authorized. A failed build must be resolved before activation.
4. After activation, use a fresh interactive terminal outside a project Nix shell
   to run `./scripts/verify-tools.sh`, inspect `type -a` for changed tools, and
   exercise their relevant integrations. Prefer focused checks over rerunning
   unrelated editor tests. Report any checks that could not be performed.

Summarize the declaration changes, whether activation occurred, and validation
results. Keep commits and pushes within the user's explicit scope. Use the
README's recovery instructions if an activated change needs reverting; Home
Manager rollback does not revert writable checkout files or local shell edits.
