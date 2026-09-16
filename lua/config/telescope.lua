local telescope = require('telescope')
local actions = require('telescope.actions')

local function ivy(options)
  return vim.tbl_deep_extend('force', { theme = 'ivy', layout_config = { height = 20 } }, options or {})
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
    buffers = ivy({
      show_all_buffers = true,
      sort_lastused = true,
      mappings = { i = { ['<C-c>'] = 'delete_buffer' } },
    }),
    commands = ivy(),
    find_files = ivy({ find_command = { 'rg', '--files', '--hidden', '-g', '!.git/' } }),
    live_grep = ivy(),
    lsp_definitions = ivy(),
    lsp_workspace_symbols = ivy(),
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
