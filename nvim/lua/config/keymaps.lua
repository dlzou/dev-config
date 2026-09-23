local map = vim.keymap.set
local function normal(lhs, rhs, desc)
  map('n', lhs, rhs, { silent = true, desc = desc })
end

map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
normal('<C-z>', '<Nop>', 'Disable suspend')
normal('p', 'p=`]', 'Paste and indent')
normal('P', 'P=`[', 'Paste before and indent')
map('x', '<C-c>', '"+y')
map('c', '<C-v>', '<C-r>+')
map('i', '<C-v>', '<C-g>u<C-r>+')
map('i', '<CR>', '<CR><C-g>u')
for lhs, rhs in pairs({
  ['<C-d>'] = '<Del>', ['<C-f>'] = '<Right>', ['<C-b>'] = '<Left>',
  ['<C-p>'] = '<Up>', ['<C-n>'] = '<Down>',
  ['<C-a>'] = '<C-o>^', ['<C-e>'] = '<C-o>$',
}) do
  map('i', lhs, rhs)
end
map('t', '<C-g>', '<C-\\><C-n>', { desc = 'Leave terminal input mode' })
-- Preserve the old backslash prefix alongside Space.
map('n', '\\', '<Space>', { remap = true })

normal('<leader>n', '<cmd>nohlsearch<CR>', 'Clear search highlight')
normal('<leader>t', '<cmd>terminal<CR>', 'Terminal')
