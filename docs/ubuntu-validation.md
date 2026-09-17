# Ubuntu validation

Run these checks on the actual Ubuntu machine as your normal user. Linux profile
evaluation on macOS does not verify Linux builds or shell/runtime behavior.

## Prepare

1. Clone this repository at the revision being validated and retain its
   `flake.lock`. Choose any location, such as `~/dev-config`. Record the revision
   with `git rev-parse HEAD` and the lockfile checksum with `sha256sum flake.lock`.
2. Check `uname -m`: the helper selects `ubuntu` for x86_64 and `ubuntu-arm64` for
   aarch64/arm64. It detects the current username, home, and checkout path.
3. Back up the shell startup files you will edit and any existing Neovim, Starship,
   Ghostty, and user Nix configuration. Keep those backups outside the repository. Preserve
   aliases, SSH-agent/proxy/certificate setup, Conda, and work-tool initialization.
4. Inspect `type -a nvim fd fzf uv clangd` in an ordinary terminal. Look for manual
   binaries in `~/bin`, Snap/apt installations, and apt-specific fzf sourcing under
   `/usr/share` that could conflict with the new shell integration.
5. Install Nix following the [root README](../README.md), then build from the
   checkout before changing shell integration:

   ```sh
   ./scripts/setup-home.sh --build
   ```

Resolve build failures before activation. Existing tools should remain installed
throughout validation.

## Activate and test

1. Move an existing `~/.config/nvim` directory aside without deleting it. Preserve
   any Starship preferences you want to merge into the shared TOML, then run:

   ```sh
   ./scripts/setup-home.sh --switch
   ```

2. Follow the README's shell-integration instructions. Remove duplicate fzf and
   Starship hooks, transfer shared fzf options into `home.nix`, and source the
   generated integration last. Keep work-tool and Conda initialization local.
3. Open a fresh terminal. Run `./scripts/verify-tools.sh` from the checkout and
   repeat `type -a` for the migrated tools. Check fzf's Ctrl-R/Ctrl-T, Starship
   symbols with a Nerd Font, tmux, and existing work commands. If using Ghostty,
   install it separately (1.2.3+) and validate/reload its shared configuration. Confirm Git/SSH and
   corporate-network workflows still use the intended local settings.
4. Open Neovim and let plugin/parser installation complete. Check dependency
   health, Telescope, Yazi, and native plugin builds. Confirm basedpyright/Ruff
   attach to Python and clangd attaches to C/C++. Exercise manual formatting and
   confirm saving alone does not format.
5. Run one existing Python project's uv commands/tests. Confirm Neovim resolves
   its environment when launched through `uv run nvim .` or project settings.
6. Run `--switch` again and open another terminal. Check for configuration
   collisions, duplicate prompt hooks, and duplicate key bindings.

Record the architecture, repository revision, lockfile checksum, executable
selection, successful checks, and failures. Exclude credentials and private shell
contents from shared output. Update [validation status](rollout-status.md) only
with checks actually completed on Ubuntu.

Retain old installations until the replacement works reliably. Inspect apt's
proposed removals and dependencies before selectively removing redundant personal
tools. Leave system packages, drivers, CUDA, Docker, system Python, and vendor/work
tools under their existing management.
