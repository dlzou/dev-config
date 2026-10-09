vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.timeout = true
vim.opt.timeoutlen = 750

-- Preserve the old backslash prefix alongside Space.
vim.keymap.set('n', '\\', '<Space>', { remap = true })
vim.keymap.set('n', '<leader>n', '<cmd>nohlsearch<CR>',
  { silent = true, desc = 'Clear search highlight' })
