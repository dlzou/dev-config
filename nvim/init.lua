-- No Python remote plugins are used; native LSP does not need this host.
vim.g.loaded_python3_provider = 0

require('config.shared')

if vim.g.vscode then
  require('config.vscode')
else
  require('config.options')
  require('config.keymaps')
end
require('config.lazy')
