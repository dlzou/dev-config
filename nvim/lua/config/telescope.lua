local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup {
  defaults = {
    layout_strategy = 'flex',
    sorting_strategy = 'ascending',
    layout_config = {
      width = 0.8,
      height = 0.8,
      prompt_position = 'top',
      flip_columns = 120,
      flip_lines = 40,
    },
    mappings = {
      i = {
        ['<Esc>'] = actions.close,
        -- Do not wait for vim-surround's global Ctrl-G s/S sequences.
        ['<C-g>'] = { actions.close, type = 'action', opts = { nowait = true } },
        ['<C-c>'] = false,
      },
      n = { ['<C-g>'] = { actions.close, type = 'action', opts = { nowait = true } } },
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
    buffers = {
      path_display = { 'filename_first' },
      show_all_buffers = true,
      sort_lastused = true,
      mappings = { i = { ['<C-c>'] = 'delete_buffer' } },
    },
    find_files = { find_command = { 'rg', '--files', '--hidden', '-g', '!.git/' } },
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
