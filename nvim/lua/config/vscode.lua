local function action(lhs, command, desc)
  vim.keymap.set('n', lhs, function()
    require('vscode').action(command)
  end, { silent = true, desc = desc })
end

action('<leader>ff', 'workbench.action.quickOpen', 'Find files')
action('<leader>fg', 'workbench.action.findInFiles', 'Search text')
action('<leader>gs', 'workbench.view.scm', 'Source control')
