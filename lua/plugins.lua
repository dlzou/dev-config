return {
  {
    'loctvl842/monokai-pro.nvim',
    priority = 1000,
    config = function()
      require('monokai-pro').setup({ filter = 'classic', transparent_background = false })
      vim.cmd.colorscheme('monokai-pro-classic')
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'loctvl842/monokai-pro.nvim' },
    opts = {
      options = {
        theme = 'monokai-pro',
        section_separators = '',
        component_separators = { left = '|', right = '|' },
      },
      sections = {
        lualine_b = { 'branch', 'diagnostics' },
        lualine_c = { { 'filename', path = 1, shorting_target = 50 } },
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
    lazy = false,
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
    'nvim-tree/nvim-tree.lua',
    lazy = false,
    keys = {
      { '<leader>ft', '<cmd>NvimTreeToggle<CR>', silent = true, desc = 'File tree' },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = { disable_netrw = false },
  },
  {
    'mbbill/undotree',
    lazy = false,
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<CR>', silent = true, desc = 'Undo tree' },
    },
  },
  {
    'tpope/vim-fugitive',
    lazy = false,
    keys = {
      { '<leader>gdv', '<cmd>Gvdiffsplit!<CR>', silent = true, desc = 'Git conflict diff' },
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
    lazy = false,
    keys = {
      { '<leader>gv', '<cmd>DiffviewOpen<CR>', silent = true, desc = 'Git diff view' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function() require('config.lsp') end,
  },
  {
    'hrsh7th/nvim-cmp',
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
  { 'folke/trouble.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' }, opts = {} },
}
