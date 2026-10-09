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
   installation if needed, and activation. For a separate build check, run
   `./scripts/setup-home.sh --build` first. Preserve local
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

## Graphical login

A terminal's `.bashrc` hook does not update an already-running desktop session.
After the [startup-chain inspection](#bash-startup-order), back up `.profile` and
any login file you need to edit outside the checkout. At the end of `.profile`,
add this hook for noninteractive login; interactive Bash uses its existing
`.bashrc` hook:

```sh
case $- in
  *i*) ;;
  *)
    if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/dev-config/shell.sh" ]; then
      . "${XDG_CONFIG_HOME:-$HOME/.config}/dev-config/shell.sh"
    fi
    ;;
esac
```

If `.bash_profile` or `.bash_login` takes precedence, ensure that the active file
sources `.profile` once, preserving existing initialization and avoiding cycles.
Set a custom `XDG_CONFIG_HOME` before this hook if needed. The generated integration
loads session variables in noninteractive shells without starting fzf or Starship.
These remain manual setup edits; activation does not rewrite startup files.

Activate the profile, then **fully log out of the desktop and log back in**.
Opening another terminal or reattaching tmux does not refresh the desktop's
environment. For GNOME, inspect both environments:

```sh
systemctl --user show-environment | grep -E '^(PATH|XDG_DATA_DIRS)='
pid=$(pgrep -u "$(id -u)" -x gnome-shell | head -n 1)
tr '\0' '\n' < "/proc/$pid/environ" | grep -E '^(PATH|XDG_DATA_DIRS)='
```

Confirm the configured personal profile's `bin` is first on PATH and its `share`
is in `XDG_DATA_DIRS`; retain system and existing Flatpak/Snap data directories.
Ubuntu 24.04's GDM X11 session sources `.profile`; GNOME 50's Wayland session uses
the user's login shell. With Bash, the login-file precedence above therefore
matters. Recheck the environment after an upgrade rather than assuming success.

Follow the [terminal and editor association instructions](reference.md#ubuntu-default-terminal-and-editor),
then verify:

- `xdg-terminal-exec --print-id` reports `com.mitchellh.ghostty.desktop`.
- `gio mime text/plain` and `gio mime text/x-log` select `nvim.desktop`.
- Open a text file and a log file from the file manager, including a filename
  containing spaces. Each opens Neovim in Ghostty; `:echo v:progpath` resolves to
  the Nix Neovim, and `:echo exepath('basedpyright-langserver')` finds the profile's
  language server.
- Ctrl-Alt-T still opens Ghostty, and fresh interactive terminals pass
  `./scripts/verify-tools.sh` with working fzf shortcuts and one Starship prompt.

Keep old installations until these checks pass. Restore backed-up startup files
and log out/in to undo the login hook; restore associations as described in the
reference. Clipboard behavior remains covered separately below.

## Clipboard checks

After applying the [tmux configuration](reference.md#tmux-and-clipboard), verify:

- Inspect `DISPLAY` / `WAYLAND_DISPLAY` and `command -v wl-copy wl-paste xclip xsel`.
  Desktop clipboard tools can come from the host; they are not required by the
  Nix tool verifier. In Neovim, use `:echo provider#clipboard#Executable()` to
  check automatic selection.
- `infocmp tmux-256color` succeeds, a new tmux window has `TERM=tmux-256color`, and
  `tmux info` lists a usable `Ms` clipboard capability with Ghostty attached.
- Test tmux copy mode, Neovim `"+y`/visual Ctrl-C, and Neovim inside tmux, both in
  local Ubuntu Ghostty and from Mac Ghostty over SSH. Copy a distinct marker for
  each case and paste into an app on the expected desktop: Ubuntu locally, Mac
  over plain SSH with no forwarded/inherited desktop environment. Confirm that
  the remote Ubuntu desktop clipboard remains unchanged in that SSH case.
- Locally, test Neovim clipboard reads from another app using `"+p` and mapped
  Ctrl-V. With the tmux provider, compare reads against its paste buffer; OSC 52
  reads may prompt/time out. Test Ghostty paste separately.
- Confirm ordinary Neovim y/d/p stay internal, pane-navigation and copy-mode keys
  work, and reattachment between local/remote use selects the intended clipboard
  after checking the pane environment and restarting Neovim.

Record observed providers separately from successful desktop copy/paste tests.

## Activate and test

1. Complete [activation](../README.md#3-activate) and
   [shell integration](../README.md#4-connect-the-shell). Check that
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
   Ghostty, follow its [installation and configuration checks](reference.md#ghostty).
   After switching and reloading Ghostty, check Ctrl-Shift-Arrows in a split layout;
   Ctrl-Alt-Arrows should no longer move between Ghostty splits.
   In an SSH session with `TERM=xterm-ghostty`, confirm `infocmp xterm-ghostty`
   succeeds and `TERMINFO_DIRS` includes the system terminfo directories. Start
   `tmux -L terminfo-check -f /dev/null new-session` without a per-command
   `TERMINFO` override; exit the test session afterward.
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
system and work tooling described in the
[development-tool reference](reference.md#compilers-and-project-environments).
