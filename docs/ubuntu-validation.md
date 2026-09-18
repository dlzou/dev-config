# Ubuntu validation

Run these checks on the actual Ubuntu machine as your normal user. Linux profile
evaluation on macOS does not verify Linux builds or shell/runtime behavior.

## Prepare

1. Use the repository revision and `flake.lock` being validated. Record them with
   `git rev-parse HEAD` and `sha256sum flake.lock`.
2. Check `uname -m`: the helper selects `ubuntu` for x86_64 and `ubuntu-arm64` for
   aarch64/arm64.
3. Inspect `type -a nvim fd fzf uv clangd cc c++` in an ordinary terminal. Look for
   manual binaries in `~/bin`, Snap/apt installations, and apt-specific fzf sourcing under
   `/usr/share` that could conflict with the new shell integration.
4. Follow the [installation guide](../README.md#install), including backups, Nix
   installation if needed, and building before activation. Preserve local
   SSH-agent/proxy/certificate setup and work-tool initialization.

Keep existing installations throughout validation. Check `cc --version` and
`c++ --version`; keep the existing Ubuntu compiler and inspect any `CC`/`CXX`
overrides used by work or CUDA builds. If the compiler is missing, install
`build-essential` as described in the main setup guide.

## Bash startup order

Inspect the actual login chain before editing: Bash reads the first available
`~/.bash_profile`, `~/.bash_login`, or `~/.profile`. A custom `.bash_profile` can
prevent `.profile` from running. Interactive non-login Bash reads `.bashrc`.

Ubuntu's usual `.profile` sources `.bashrc` and then prepends `~/bin` and
`~/.local/bin`. This can put an old Neovim, fd, or uv ahead of the Nix profile even
when the dev-config hook is last in `.bashrc`.

After backing up the affected files outside the checkout:

1. In the usual `.profile`, move its existing conditional PATH additions for
   `~/bin` and `~/.local/bin` above the block that sources `.bashrc`. Keep their
   existing relative order and directory checks; do not remove the directories.
2. With a custom login file, inspect how it loads `.profile`/`.bashrc` and apply
   the same ordering to that existing chain. Do not add a second source of
   `.bashrc` or a second dev-config hook.
3. Keep the generated dev-config hook last in `.bashrc`, replacing superseded
   apt fzf and standalone Starship hooks as described in the main guide. Preserve
   existing history handling, `PROMPT_COMMAND`, Conda, and work initialization.

These are one-time local setup edits, not automatic activation changes. Later
explicit project activation may intentionally put its tools first on PATH.

## Activate and test

1. Complete [activation](../README.md#3-build-and-activate) and
   [shell integration](../README.md#4-integrate-the-existing-shell). Check that
   apt's fzf hooks have been replaced and the [Bash startup order](#bash-startup-order)
   prevents `~/bin` from shadowing the Nix profile.
2. Test fresh login and non-login interactive Bash (`bash -lic` and `bash -ic`,
   each with a command to run the verification script from the checkout). Also
   test the ordinary terminal. Run `./scripts/verify-tools.sh` outside a project
   Nix shell and repeat `type -a` for migrated tools plus `cc` and `c++`. Confirm
   compilers resolve to the intended system installation, not `/nix/store`.
   Compile and run small C and C++ programs and exercise a representative existing
   CUDA/work build without changing its toolkit or compiler settings.
   Check fzf's Ctrl-R/Ctrl-T, Starship symbols with a Nerd Font, tmux, and existing work commands. Confirm Git/SSH and
   corporate-network workflows still use the intended local settings. If using
   Ghostty, follow its [installation and configuration checks](../README.md#ghostty-terminal).
3. Open Neovim and let plugin/parser installation complete. Check dependency
   health, Telescope, Yazi, and fresh native plugin/parser builds with the system
   compiler. A cached binary alone does not validate the new compiler selection.
   Confirm basedpyright/Ruff attach to Python and clangd attaches to C/C++. Exercise manual formatting and
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
