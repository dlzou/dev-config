return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup({ style = 'moon', transparent = false })
      vim.cmd.colorscheme('tokyonight-moon')
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/tokyonight.nvim' },
    opts = {
      options = {
        theme = 'tokyonight-moon',
        section_separators = { left = '', right = '' },
        component_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diagnostics' },
        lualine_c = { { 'filename', path = 1, shorting_target = 50 } },
        lualine_z = { 'location' },
      },
    },
  },
  {
    'mhinz/vim-startify',
    lazy = false,
    keys = {
      { '<leader>sc', '<cmd>SClose<CR>', silent = true, desc = 'Close session' },
      { '<leader>sd', '<cmd>SDelete<CR>', silent = true, desc = 'Delete session' },
      { '<leader>sl', '<cmd>SLoad<CR>', silent = true, desc = 'Load session' },
      { '<leader>ss', '<cmd>SSave<CR>', silent = true, desc = 'Save session' },
      { '<leader>st', '<cmd>Startify<CR>', silent = true, desc = 'Start screen' },
    },
    init = function()
      vim.g.startify_custom_header = { '   Neovim', '' }
      vim.g.startify_files_number = 5
      vim.g.startify_session_persistence = 1
      vim.g.startify_session_dir = vim.fn.stdpath('data') .. '/session'
      vim.fn.mkdir(vim.g.startify_session_dir, 'p')
    end,
  },
  { 'lewis6991/gitsigns.nvim', opts = {} },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function() require('config.treesitter') end,
  },
  {
    'OXY2DEV/markview.nvim',
    -- Markview defers rendering internally; initialize after the colorscheme.
    lazy = false,
    dependencies = { 'folke/tokyonight.nvim' },
    opts = function()
      local callbacks = {}
      for name, callback in pairs(require('markview.spec').default.preview.callbacks) do
        callbacks[name] = function(...)
          -- Keep upstream conceal changes from becoming defaults for other buffers.
          local level, cursor = vim.go.conceallevel, vim.go.concealcursor
          callback(...)
          vim.go.conceallevel, vim.go.concealcursor = level, cursor
        end
      end
      return { preview = { enable = false, filetypes = { 'markdown' }, callbacks = callbacks } }
    end,
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('UserMarkviewKeys', { clear = true }),
        pattern = 'markdown',
        callback = function(event)
          vim.keymap.set('n', '<leader>mp', '<cmd>Markview toggle<CR>',
            { buffer = event.buf, silent = true, desc = 'Toggle Markdown preview' })
          vim.keymap.set('n', '<leader>ms', '<cmd>Markview splitToggle<CR>',
            { buffer = event.buf, silent = true, desc = 'Toggle Markdown split preview' })
        end,
      })
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      scope = { enabled = true },
      exclude = { buftypes = { 'terminal' }, filetypes = { 'help', 'lazy', 'startify' } },
    },
  },
  'tpope/vim-surround',
  'tpope/vim-sleuth',
  {
    'nvim-telescope/telescope.nvim',
    lazy = true,
    cmd = 'Telescope',
    keys = {
      { '<leader>c', '<cmd>Telescope commands<CR>', silent = true, desc = 'Commands' },
      { '<leader>fb', '<cmd>Telescope buffers<CR>', silent = true, desc = 'Buffers' },
      { '<leader>ff', '<cmd>Telescope find_files<CR>', silent = true, desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<CR>', silent = true, desc = 'Search text' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function() require('config.telescope') end,
  },
  {
    'mikavilpas/yazi.nvim',
    version = '*',
    cmd = 'Yazi',
    keys = {
      { '<leader>fy', '<cmd>Yazi<CR>', silent = true, desc = 'Yazi file browser' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      open_for_directories = false,
      floating_window_scaling_factor = 0.8,
      integrations = {
        grep_in_directory = 'telescope',
        grep_in_selected_files = 'telescope',
      },
      keymaps = {
        -- These optional actions need grug-far, snacks.picker, or GNU realpath.
        replace_in_directory = false,
        open_and_pick_window = false,
        copy_relative_path_to_selected_files = false,
      },
      hooks = {
        on_yazi_ready = vim.schedule_wrap(function(buffer, _, api)
          if not vim.api.nvim_buf_is_valid(buffer) then return end
          -- Quit through Yazi so its normal cleanup and focus restoration run.
          vim.keymap.set({ 't', 'n' }, '<C-g>', function()
            api:emit_to_yazi({ 'quit' })
          end, { buffer = buffer, desc = 'Close Yazi' })
        end),
      },
    },
  },
  {
    'mbbill/undotree',
    lazy = true,
    cmd = { 'UndotreeToggle', 'UndotreeShow', 'UndotreeHide', 'UndotreeFocus', 'UndotreePersistUndo' },
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<CR>', silent = true, desc = 'Undo tree' },
    },
  },
  {
    'tpope/vim-fugitive',
    lazy = false,
    keys = {
      { '<leader>gs', '<cmd>Git<CR>', silent = true, desc = 'Git status' },
      { '<leader>gb', '<cmd>Git blame<CR>', silent = true, desc = 'Git blame' },
    },
  },
  {
    'rhysd/conflict-marker.vim',
    init = function()
      vim.g.conflict_marker_begin = '^<<<<<<< .*$'
      vim.g.conflict_marker_end = '^>>>>>>> .*$'
    end,
  },
  {
    'sindrets/diffview.nvim',
    lazy = true,
    cmd = {
      'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewClose', 'DiffviewFocusFiles',
      'DiffviewToggleFiles', 'DiffviewRefresh', 'DiffviewLog',
    },
    keys = {
      { '<leader>dv', '<cmd>DiffviewOpen<CR>', silent = true, desc = 'Review changes' },
      { '<leader>dh', '<cmd>DiffviewFileHistory %<CR>', silent = true, desc = 'File history' },
      { '<leader>dH', '<cmd>DiffviewFileHistory<CR>', silent = true, desc = 'Repository history' },
      { '<leader>dq', '<cmd>DiffviewClose<CR>', silent = true, desc = 'Close diff view' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      keymaps = {
        view = {
          { 'n', '<C-g>', '<cmd>DiffviewClose<CR>', { desc = 'Close diff view' } },
        },
        file_panel = {
          { 'n', '<C-g>', '<cmd>DiffviewClose<CR>', { desc = 'Close diff view' } },
        },
        file_history_panel = {
          { 'n', '<C-g>', '<cmd>DiffviewClose<CR>', { desc = 'Close diff view' } },
        },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function() require('config.lsp') end,
  },
  {
    'hrsh7th/nvim-cmp',
    lazy = true,
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer',
      { 'windwp/nvim-autopairs', opts = {} },
    },
    config = function() require('config.cmp') end,
  },
  {
    'RRethy/vim-illuminate',
    config = function() require('illuminate').configure({ delay = 200 }) end,
  },
  {
    'folke/trouble.nvim',
    lazy = true,
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
}
