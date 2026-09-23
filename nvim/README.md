# Neovim configuration

Neovim 0.12+ with Python/C++ language support.
Configuration is Lua; lazy.nvim manages plugins pinned in `lazy-lock.json`.

## Setup

This directory is the Neovim part of the personal development configuration.
Follow the [repository setup instructions](../README.md) to install the shared
Nix/Home Manager profile and link `~/.config/nvim` to this checkout directory.

### First launch and updates

The first launch downloads lazy.nvim, plugins, and syntax parsers and builds
Telescope's native sorter. Wait for installation to finish, then reopen Neovim;
a buffer opened before its parser was installed may not yet have highlighting.
Native builds use the system C/C++ compiler; see the
[toolchain prerequisites](../README.md#2-install-nix).

- `:checkhealth userconfig` checks external tools and minimum versions; also use
  `:checkhealth lazy`, `:checkhealth nvim-treesitter`, `:checkhealth vim.lsp`,
  `:checkhealth telescope`, and `:checkhealth yazi` (open each picker/browser once
  first to load its plugin).
- `:Lazy restore` restores plugin revisions from the lockfile; `:Lazy update`
  intentionally updates them. Keep the resulting `lazy-lock.json` with the config.
- `:Lazy clean` removes cached plugins no longer used by this configuration.
- `:TSUpdate` updates syntax parsers. Parsers follow nvim-treesitter's definitions;
  their compiled artifacts are local to each machine.
- For external tools, see the repository's [update procedure](../README.md#updates)
  and [minimum versions](../README.md#configuration-files).

Telescope uses `rg`; missing `fd` produces only a health-check warning.

### Plugin loading

Telescope, Diffview, Trouble, Undotree, and Yazi load on their commands or
shortcuts. Completion and autopairs load when you first enter insert mode;
press Tab to request completion. Markview initializes after the colorscheme and
defers rendering internally. Use `:Lazy profile` to inspect plugin timings.

## Language support

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
project's dependencies.

## Appearance

The theme is `tokyonight-moon`. Change its setup and the Lualine theme in
[lua/plugins.lua](lua/plugins.lua).

## Keys and behavior

The leader is **Space**; backslash remains an alias for normal-mode leader commands.
Incomplete mapped sequences time out after 750 ms. Completion stays manual.

| Keys | Action |
| --- | --- |
| Space c | Command picker |
| Space fb / ff / fg | Buffers / files / text search |
| Space fy | Yazi file browser at the current file |
| Space mp / ms in Markdown | Toggle current-buffer preview / split preview |
| Space gs / gb | Fugitive: Git status / blame current file |
| Space dv / dq | Diffview: review changes / close view |
| Space dh / dH | Diffview: current-file history / repository history |
| Ctrl-G in Diffview (normal mode) | Close the diff view from a diff buffer, file list, or history panel |
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
remain off. Python uses Neovim's native indentation; LSP snippets use `vim.snippet`.
Undo history persists across restarts in Neovim's standard undo directory.
Surround, indentation detection, Git tools, and Startify sessions are enabled.

## Markdown preview

Markdown opens as raw source by default. Enable
[Markview](https://github.com/OXY2DEV/markview.nvim) on demand with the shortcuts
below. Headings, lists, tables, code blocks, inline HTML, YAML frontmatter, and
supported math notation are rendered inside Neovim. Math
uses text decorations and Unicode symbols, not full LaTeX typesetting.

- **Space mp** (`:Markview toggle`) toggles preview for the current buffer.
- **Space ms** (`:Markview splitToggle`) opens a synchronized side-by-side preview.
  Press it again from the source buffer to close the preview.
- These normal-mode shortcuts are buffer-local to Markdown. When enabled, inline
  preview is shown in normal mode; insert mode exposes the source for editing.
- Run `:checkhealth markview` to check dependencies. Markdown, LaTeX, HTML, and YAML
  parsers install automatically; after first installation, reopen the file if
  previews are incomplete. Optional parsers for other formats are not required.

## Git workflow

Use **Fugitive** for staging and commits: `Space gs` opens Git status, where `=`
expands an inline diff, `s` stages the file or hunk under the cursor, `u` unstages
it, and `cc` starts a commit. `Space gb` opens blame for the current file. Press
`g?` in Fugitive status for help.

Use **Diffview** for reviewing changes (`Space dv`), file history (`Space dh`),
and repository history (`Space dH`). During a merge or rebase, open a conflicted
file from its file panel to see the source versions and editable result.

These normal-mode shortcuts are local to Diffview's diff buffers:

| Keys | Action |
| --- | --- |
| `]x` / `[x` | Next / previous conflict |
| Space co / ct | Choose ours / theirs for the current conflict |
| Space cb / ca | Choose the base version / keep both sides |
| `g?` | Show Diffview shortcuts |

You can edit the result manually, including refining a combined result. Save with
`:w`, then stage the resolved file with `s` in Diffview's file panel or Fugitive
status. During a rebase, inspect the source versions carefully: ours/theirs refer
to Git's merge stages, not necessarily your branch versus someone else's.

`Space dq` closes Diffview; Ctrl-G also closes it locally from its diff buffers,
file panel, or history panel. Outside Diffview, normal-mode Ctrl-G retains its
usual behavior. Fugitive's `:Gvdiffsplit!` remains available for an occasional
current-file comparison, using ordinary Neovim splits.

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
`Space fy` to open Yazi.

Shared HTML, SVG, and CSV/TSV opener choices are documented in the
[repository's Yazi guide](../README.md#yazi-file-openers). Enter still selects the
file for Neovim; Shift-O offers the configured openers.

Inside Yazi:

| Keys | Action |
| --- | --- |
| h / j / k / l | Parent directory / down / up / enter directory |
| Enter | Open the selected file in Neovim |
| Shift-O | Choose an external opener for the selected file |
| Ctrl-G / q | Close Yazi |
| Esc | Cancel a Yazi action or selection |
| Ctrl-S | Telescope text search in the hovered directory/file's parent, or selected files |
| Ctrl-V / Ctrl-X / Ctrl-T | Open in a vertical split / horizontal split / tab |
| F1 | Neovim integration shortcuts |
| ~ | Yazi's own shortcut help |

`:Yazi cwd` starts at Neovim's working directory; `:Yazi toggle` resumes the previous
Yazi location. Browsing does not change Neovim's working directory. Ctrl-S uses the
[Telescope layout](#telescope-layout). To leave terminal mode while keeping Yazi
open, use Neovim's native `Ctrl-\` then `Ctrl-N` sequence.
Ctrl-G closes Yazi or Telescope in either input or normal mode; in a regular
terminal it returns to normal mode with the shell still running (press `i` to resume).

Yazi and `ya` are installed together and should have matching versions. Run
`:checkhealth yazi` for integration checks after opening Yazi once to load the
plugin. For standalone preview/search helpers, see the
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

### Python remote-plugin host

Neovim's Python remote-plugin host is disabled in `init.lua`; the pinned Nix
package wrapper also disables it. Python editing, native indentation, basedpyright,
and Ruff do not require this host. Enabling Python remote plugins or `:python3`
would require a provider-enabled Neovim package and a Python host with `pynvim`,
as well as removing the Lua disable setting.

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
