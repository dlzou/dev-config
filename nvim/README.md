# Neovim configuration

Neovim 0.12+ with classic Monokai and Python/C++ language support.
Configuration is Lua; lazy.nvim manages plugins pinned in `lazy-lock.json`.

## Setup

This directory is the Neovim part of the personal development configuration.
Follow the [repository setup instructions](../README.md) to install the shared
Nix/Home Manager profile and link `~/.config/nvim` to this checkout directory.
The optional Homebrew installer is `../scripts/setup-macos.sh`.

External executables come from Nix (or the Homebrew fallback); Mason is not used.
Project dependencies and Python virtual environments remain separate. The Lua
configuration and plugin lockfile stay writable in the checkout.

### First launch and updates

The first launch downloads lazy.nvim, plugins, and syntax parsers and builds
Telescope's native sorter. Wait for installation to finish, then reopen Neovim;
a buffer opened before its parser was installed may not yet have highlighting.

- `:checkhealth userconfig` checks external tools and minimum versions; also use
  `:checkhealth lazy`, `:checkhealth nvim-treesitter`, `:checkhealth vim.lsp`,
  `:checkhealth telescope`, and `:checkhealth yazi` (open each picker/browser once
  first to load its plugin).
- `:Lazy restore` restores plugin revisions from the lockfile; `:Lazy update`
  intentionally updates them. Keep the resulting `lazy-lock.json` with the config.
- `:Lazy clean` removes cached plugins no longer used by this configuration.
- `:TSUpdate` updates syntax parsers. Parsers follow nvim-treesitter's definitions;
  their compiled artifacts are local to each machine.
- For Nix-managed external tools, run `nix flake update` from the repository root,
  review `flake.lock`, then build and apply with `scripts/setup-home.sh`. For the
  Homebrew fallback, explicitly use `brew upgrade <formula>`.

Required minimums: Neovim 0.12.0, tree-sitter CLI 0.26.1, and Ruff 0.5.3 (native
server support for the pinned LSP configuration). `fd` is included as a useful
standalone utility; Telescope continues to use `rg`, so missing fd is only a warning.

### Plugin loading

Telescope, Diffview, Trouble, Undotree, and Yazi load when you use their commands
or configured shortcuts. Completion (`nvim-cmp`), its buffer source, and autopairs
load on the first `InsertEnter` event. The lightweight LSP completion capability
setup remains available at startup so language servers advertise snippet support.
Completion still requires Tab; entering insert mode does not request suggestions.

The theme/status line, Startify, Treesitter, LSP setup, Git signs/Fugitive,
indentation tools, surround, conflict highlighting, and word illumination load at
startup. `:Lazy profile` shows plugin timings; deferred loading moves work to first
use rather than eliminating it.

## Language support

Neovim's Python remote-plugin host is disabled in `init.lua`; the pinned Nix
package wrapper also disables it. Python editing, native indentation, basedpyright,
and Ruff do not require this host. Enabling Python remote plugins or `:python3`
would require a provider-enabled Neovim package and a Python host with `pynvim`,
as well as removing the Lua disable setting.

**Python:** basedpyright provides completion, navigation, signature help, and type
checking. Its defaults are `standard` checking and `openFilesOnly` diagnostics.
Project `pyrightconfig.json` or `[tool.basedpyright]` settings in `pyproject.toml`
can override applicable analysis defaults. Launch Neovim from an activated virtual
environment, or configure the project's environment explicitly.

Ruff's native server provides linting, formatting, import organization, and fixes.
Ruff reads the project's `pyproject.toml`, `ruff.toml`, or `.ruff.toml`; this config
does not impose lint rules, line length, or formatting style. Basedpyright's import
organizer and Ruff's hover are disabled so the servers have clear responsibilities.
Some diagnostics may overlap because basedpyright retains full type analysis.
Fix-all uses Ruff's safe-fix defaults unless the project explicitly enables unsafe
fixes. Formatting, import organization, and fixes are manual, with no format-on-save.

References: [basedpyright settings](https://docs.basedpyright.com/latest/configuration/language-server-settings/)
and [Ruff's Neovim setup](https://docs.astral.sh/ruff/editors/setup/).

**C/C++:** clangd runs from PATH. Generate `compile_commands.json` in the project
for accurate include paths and build flags. Language servers do not install your
project's dependencies. Debugging and Go integrations are not configured.

## Appearance

`loctvl842/monokai-pro.nvim` uses its classic filter and the `monokai-pro-classic`
colorscheme, with a matching Lualine theme. Main background (`#272822`) and foreground
(`#fdfff1`) come from the plugin's classic palette. Floating windows and sidebars
can use darker shades. Terminal themes, including Ghostty's, are configured
separately from this repository.

## Keys and behavior

The leader is **Space**; backslash remains an alias for normal-mode leader commands.
Incomplete mapped sequences time out after 750 ms. Completion stays manual.

| Keys | Action |
| --- | --- |
| Space c | Command picker |
| Space fb / ff / fg | Buffers / files / text search |
| Space fy | Yazi file browser at the current file |
| Space gdv / gdh / gdl | Conflict diff / get left / get right |
| Space gv | Git diff view (`:DiffviewClose` to close) |
| Space ld / ll / ln / lr / ls | Definitions / diagnostics / rename / references / workspace symbols |
| Space la | LSP code actions |
| Space lf / li / lx | Python: Ruff format / organize imports / fix all |
| Space ss / sl / sc / sd / st | Save / load / close / delete session / Startify |
| Space t / u / n | Terminal / undo tree / clear search highlight |
| Tab / Shift-Tab in insert or select mode | Request/navigate completion or move through native snippet fields |
| Enter / Ctrl-Z in completion | Accept / cancel |
| Ctrl-K in insert mode | Native signature help, when the server supports it |
| gcc / gc{motion} / visual gc | Native comment toggle |
| Ctrl-G in a terminal | Leave terminal input mode; keep the shell running |
| Ctrl-G in Yazi or Telescope | Close the browser/picker and return to editing |
| Esc | Passed through to terminal applications; still closes Telescope |
| Ctrl-C in visual mode | Copy to system clipboard |
| Ctrl-V in insert/command mode | Paste from system clipboard |

Diagnostics appear on cursor pause and in Trouble; inline diagnostic text and signs
remain off. Python uses Neovim's native indentation. LSP snippets use `vim.snippet`;
there is no separate snippet library/source. Undo history persists across restarts
in Neovim's standard undo directory. Surround, indentation detection, Git tools,
and Startify sessions are enabled.

## Telescope layout

Configured pickers use `flex` at 80% width and height, with the prompt at the top.
The layout switches between horizontal and vertical based on available space.
Edit the shared helper in `lua/config/telescope.lua` to change dimensions or switch
thresholds. In the buffers picker, Ctrl-C deletes the selected buffer; Ctrl-G or
Esc closes the picker.

## Yazi file browser

[yazi.nvim](https://github.com/mikavilpas/yazi.nvim) opens the installed Yazi executable
in a floating terminal at 80% of the editor size. It loads on `Space fy` or `:Yazi`.
Directory arguments such as `nvim .` use Neovim's built-in netrw browser; press
`Space fy` to open Yazi. Yazi stays unloaded until requested. Telescope file/text
pickers remain available on `Space ff` and `Space fg`.

Inside Yazi:

| Keys | Action |
| --- | --- |
| h / j / k / l | Parent directory / down / up / enter directory |
| Enter | Open the selected file in Neovim |
| Ctrl-G / q | Close Yazi |
| Esc | Cancel a Yazi action or selection |
| Ctrl-S | Telescope text search in the hovered directory/file's parent, or selected files |
| Ctrl-V / Ctrl-X / Ctrl-T | Open in a vertical split / horizontal split / tab |
| F1 | Neovim integration shortcuts |
| ~ | Yazi's own shortcut help |

`:Yazi cwd` starts at Neovim's working directory; `:Yazi toggle` resumes the previous
Yazi location. Browsing does not change Neovim's working directory. Ctrl-S uses the
existing Telescope flex layout and its 80% width/height settings. To leave terminal
mode while keeping Yazi open, use Neovim's native `Ctrl-\` then `Ctrl-N` sequence.
Ctrl-G closes Yazi or Telescope in either input or normal mode; in a regular
terminal it returns to normal mode with the shell still running (press `i` to resume).

Yazi and `ya` are installed together and should have matching versions. Run
`:checkhealth yazi` for integration checks after opening Yazi once to load the
plugin. Optional grug-far replacement, Snacks window picking, and GNU-realpath-based
relative-path copying shortcuts are disabled.
Additional preview/search helpers for standalone Yazi are optional; see the
[Yazi installation guide](https://yazi-rs.github.io/docs/installation/).

## Configuration layout and troubleshooting

`init.lua` loads core settings/keymaps and lazy.nvim. `lua/plugins.lua` keeps plugin
specs and their shortcuts together; `lua/config/` contains focused feature setup.
LSP shortcuts are buffer-local and installed when servers attach.

`:messages` shows startup errors; `:Lazy` shows plugin installation/build failures.
Treesitter tolerates parsers missing during initial installation, but reports real
parser/query startup errors. Reopen the buffer after installation; use `:TSUpdate`
if an installed parser is incompatible. Missing executable/version failures include
setup instructions in `:checkhealth userconfig`. Check PATH inside the terminal
where you launch Neovim, especially after entering a Nix shell or activating a venv.

### Startup timing

`:Lazy profile` reports plugin loading costs. To capture a slow launch in the
terminal where it occurs, run:

```sh
nvim --startuptime "/tmp/nvim-startup-$(date +%s).log"
```

Append a filename or `.` to reproduce the usual launch. Capture another run
immediately afterward to compare. The log measures editor startup, not the time
until language servers finish initialization. Repeated launches can benefit from
caches, so a fast warm run does not rule out an intermittent delay.
