local parsers = { 'python', 'c', 'cpp', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline', 'bash' }
require('nvim-treesitter').install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('UserTreesitter', { clear = true }),
  pattern = { 'python', 'c', 'cpp', 'lua', 'vim', 'help', 'markdown', 'sh', 'bash' },
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
    -- Missing parsers are expected during the asynchronous first installation.
    if not lang or #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0 then return end
    local ok, err = pcall(vim.treesitter.start, event.buf, lang)
    if not ok then
      vim.schedule(function()
        vim.notify('Treesitter could not start for ' .. lang .. ': ' .. tostring(err), vim.log.levels.ERROR)
      end)
      return
    end
    -- Use Neovim's native indentation for Python.
    if vim.bo[event.buf].filetype ~= 'python' then
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

return parsers
