local path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(path) then
  local result = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', path,
  })
  if vim.v.shell_error ~= 0 then
    error('Unable to install lazy.nvim. Check Git/network access:\n' .. result)
  end
end
vim.opt.rtp:prepend(path)
require('lazy').setup({
  { import = 'plugins-shared' },
  { import = 'plugins' },
}, {
  -- Keep all specs known to Lazy so VS Code cannot mark standalone plugins unused.
  -- Shared plugins opt in with cond = true.
  defaults = { lazy = false, cond = function() return not vim.g.vscode end },
  rocks = { enabled = false },
  checker = { enabled = false },
  change_detection = { notify = false },
})
