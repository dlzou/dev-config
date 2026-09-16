vim.diagnostic.config({
  virtual_text = false,
  signs = false,
  severity_sort = true,
  float = { header = '' },
})

local attach_group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true })
local diagnostic_group = vim.api.nvim_create_augroup('UserLspDiagnostics', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  group = attach_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end
    if client.name == 'ruff' then client.server_capabilities.hoverProvider = false end

    local function map(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
    end
    map('<leader>ld', '<cmd>Telescope lsp_definitions<CR>', 'Definitions')
    map('<leader>ll', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', 'Buffer diagnostics')
    map('<leader>ln', vim.lsp.buf.rename, 'Rename symbol')
    map('<leader>la', vim.lsp.buf.code_action, 'Code actions')
    if client:supports_method('textDocument/signatureHelp', event.buf) then
      vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help,
        { buffer = event.buf, silent = true, desc = 'Signature help' })
    end
    if client.name == 'ruff' then
      map('<leader>lf', function()
        vim.lsp.buf.format({ bufnr = event.buf, name = 'ruff', timeout_ms = 5000 })
      end, 'Format Python with Ruff')
      local function ruff_action(kind)
        vim.lsp.buf.code_action({
          context = { only = { kind }, diagnostics = {} },
          filter = function(action, client_id) return client_id == client.id and action.kind == kind end,
          apply = true,
        })
      end
      map('<leader>li', function() ruff_action('source.organizeImports.ruff') end, 'Organize Python imports')
      map('<leader>lx', function() ruff_action('source.fixAll.ruff') end, 'Fix Python with Ruff')
    end
    map('<leader>lr', '<cmd>Trouble lsp_references toggle<CR>', 'References')
    map('<leader>ls', function()
      vim.ui.input({ prompt = 'Workspace symbol: ' }, function(query)
        if query then require('telescope.builtin').lsp_workspace_symbols({ query = query }) end
      end)
    end, 'Workspace symbols')

    -- Multiple clients may attach to one buffer: keep only one popup handler.
    vim.api.nvim_clear_autocmds({ group = diagnostic_group, buffer = event.buf })
    vim.api.nvim_create_autocmd('CursorHold', {
      group = diagnostic_group,
      buffer = event.buf,
      callback = function()
        if #vim.lsp.get_clients({ bufnr = event.buf }) == 0 then return end
        vim.diagnostic.open_float(nil, {
          focusable = false, scope = 'cursor',
          close_events = { 'CursorMoved', 'InsertEnter', 'BufLeave', 'WinLeave', 'WinScrolled' },
        })
      end,
    })
  end,
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config('basedpyright', {
  capabilities = capabilities,
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = { typeCheckingMode = 'standard', diagnosticMode = 'openFilesOnly' },
    },
  },
})
vim.lsp.config('ruff', { capabilities = capabilities })
vim.lsp.config('clangd', { capabilities = capabilities, filetypes = { 'c', 'cpp' } })
vim.lsp.enable({ 'basedpyright', 'ruff', 'clangd' })
