-- nvim-tree's built-in session restoration requires Neovim 0.13+.
if vim.fn.has('nvim-0.13') == 1 then return end

local pending = false
vim.api.nvim_create_autocmd('SessionLoadPost', {
  group = vim.api.nvim_create_augroup('UserTreeSession', { clear = true }),
  desc = 'Restore saved nvim-tree panes on Neovim 0.12',
  callback = function()
    -- :mksession emits this event for every buffer; restore once, after loading.
    if pending then return end
    pending = true
    vim.schedule(function()
      pending = false
      local tree = require('nvim-tree.api').tree
      local windows = {}
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if tree.is_tree_buf(buf) and vim.bo[buf].filetype ~= 'NvimTree' then
          windows[#windows + 1] = {
            win = win,
            path = vim.api.nvim_win_call(win, vim.fn.getcwd),
          }
        end
      end

      -- nvim-tree deletes old placeholder buffers when creating its real buffer.
      -- Detach all placeholders first so that this cannot close their saved panes.
      for _, saved in ipairs(windows) do
        local scratch = vim.api.nvim_create_buf(false, true)
        vim.bo[scratch].bufhidden = 'wipe'
        vim.api.nvim_win_set_buf(saved.win, scratch)
      end
      for _, saved in ipairs(windows) do
        vim.api.nvim_win_call(saved.win, function()
          tree.open({ winid = saved.win, path = saved.path })
        end)
      end
    end)
  end,
})
