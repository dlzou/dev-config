-- No Python remote plugins are used; native LSP does not need this host.
vim.g.loaded_python3_provider = 0

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')
require('config.lazy')
