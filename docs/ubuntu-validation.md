# Ubuntu validation

Run these checks on the actual Ubuntu machine as your normal user. Linux profile
evaluation on macOS does not verify Linux builds or shell/runtime behavior.

## Prepare

1. Use the repository revision and `flake.lock` being validated. Record them with
   `git rev-parse HEAD` and `sha256sum flake.lock`.
2. Check `uname -m`: the helper selects `ubuntu` for x86_64 and `ubuntu-arm64` for
   aarch64/arm64.
3. Inspect `type -a nvim fd fzf uv clangd` in an ordinary terminal. Look for manual
   binaries in `~/bin`, Snap/apt installations, and apt-specific fzf sourcing under
   `/usr/share` that could conflict with the new shell integration.
4. Follow the [installation guide](../README.md#install), including backups, Nix
   installation if needed, and building before activation. Preserve local
   SSH-agent/proxy/certificate setup and work-tool initialization.

Keep existing installations throughout validation.

## Activate and test

1. Complete [activation](../README.md#3-build-and-activate) and
   [shell integration](../README.md#4-integrate-the-existing-shell). Check that
   apt's fzf hooks have been replaced and `~/bin` does not shadow the Nix profile.
2. Open a fresh terminal. Run `./scripts/verify-tools.sh` from the checkout and
   repeat `type -a` for the migrated tools. Check fzf's Ctrl-R/Ctrl-T, Starship
   symbols with a Nerd Font, tmux, and existing work commands. Confirm Git/SSH and
   corporate-network workflows still use the intended local settings. If using
   Ghostty, follow its [installation and configuration checks](../README.md#ghostty-terminal).
3. Open Neovim and let plugin/parser installation complete. Check dependency
   health, Telescope, Yazi, and native plugin builds. Confirm basedpyright/Ruff
   attach to Python and clangd attaches to C/C++. Exercise manual formatting and
   confirm saving alone does not format.
4. Run one existing Python project's uv commands/tests. Confirm Neovim resolves
   its environment when launched through `uv run nvim .` or project settings.
5. Run `./scripts/setup-home.sh --switch` again and open another terminal. Check
   for configuration collisions, duplicate prompt hooks, and duplicate key bindings.

Record the architecture, repository revision, lockfile checksum, executable
selection, successful checks, and failures. Exclude credentials and private shell
contents from shared output. Update [validation status](rollout-status.md) only
with checks actually completed on Ubuntu.

After validation, review apt's proposed removals and dependencies before
selectively removing redundant personal tools. Retain the existing ownership of
system and work tooling described in the [repository overview](../README.md).
