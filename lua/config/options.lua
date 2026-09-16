local opt = vim.opt
opt.termguicolors = true
opt.background = 'dark'
opt.mouse = 'a'
opt.updatetime = 500
opt.timeout = true
opt.timeoutlen = 750
opt.undofile = true
opt.splitright = true
opt.number = true
opt.cursorline = true
opt.colorcolumn = '101'

-- Defaults; vim-sleuth detects the indentation of each file.
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.autoindent = true
opt.list = true
opt.listchars = { tab = '>-', trail = '!' }

vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('UserTerminal', { clear = true }),
  callback = function() vim.opt_local.number = false end,
})
