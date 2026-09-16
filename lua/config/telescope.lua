local telescope = require('telescope')
local actions = require('telescope.actions')

local function flex(options)
  return vim.tbl_deep_extend('force', {
    layout_strategy = 'flex',
    sorting_strategy = 'ascending',
    layout_config = {
      width = 0.8,
      height = 0.8,
      prompt_position = 'top',
      flip_columns = 120,
      flip_lines = 40,
    },
  }, options or {})
end

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<Esc>'] = actions.close,
        ['<C-c>'] = false,
      },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--trim",
    },
  },
  pickers = {
    buffers = flex({
      show_all_buffers = true,
      sort_lastused = true,
      mappings = { i = { ['<C-c>'] = 'delete_buffer' } },
    }),
    commands = flex(),
    find_files = flex({ find_command = { 'rg', '--files', '--hidden', '-g', '!.git/' } }),
    live_grep = flex(),
    lsp_definitions = flex(),
    lsp_workspace_symbols = flex(),
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
  },
}

telescope.load_extension('fzf')
