local M = {}

function M.check()
  local health = vim.health
  local setup = 'From your dev-config checkout, run ./scripts/setup-home.sh --switch, source the shell integration, and open a fresh terminal. '
    .. 'On macOS, the optional Homebrew fallback is ./scripts/setup-macos.sh from that checkout.'
  health.start('Neovim configuration dependencies')
  if vim.fn.has('nvim-0.12') == 1 then
    health.ok('Neovim ' .. tostring(vim.version()))
  else
    health.error('Neovim 0.12.0 or later is required.', { setup })
  end

  local dependencies = {
    { 'basedpyright' }, { 'basedpyright-langserver', check_version = false },
    { 'ruff', minimum = '0.5.3' }, { 'clangd' },
    { 'rg' }, { 'fd', optional = true }, { 'tree-sitter', minimum = '0.26.1' },
    { 'yazi' }, { 'ya' }, { 'file' },
    { 'git' }, { 'make' }, { 'cc' }, { 'curl' }, { 'tar' },
  }
  for _, dependency in ipairs(dependencies) do
    local name = dependency[1]
    local report = dependency.optional and health.warn or health.error
    if vim.fn.executable(name) ~= 1 then
      report(name .. ' is missing from PATH' .. (dependency.optional and ' (optional; Telescope uses rg).' or '.'), { setup })
    elseif dependency.check_version == false then
      health.ok(name .. ': ' .. vim.fn.exepath(name))
    else
      local ok, result = pcall(function()
        return vim.system({ name, '--version' }, { text = true }):wait(5000)
      end)
      if not ok or result.code ~= 0 then
        report(name .. ' could not run --version.', { setup })
      else
        local output = result.stdout or ''
        local version = vim.version.parse(output)
        if dependency.minimum and (not version or not vim.version.ge(version, dependency.minimum)) then
          report(name .. ' requires version ' .. dependency.minimum .. ' or later.', { setup })
        else
          health.ok(name .. ': ' .. vim.fn.exepath(name) .. '\n' .. (output:match('[^\n]+') or 'Available'))
        end
      end
    end
  end
end

return M
