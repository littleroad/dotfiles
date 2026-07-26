-- Keymaps: editor chrome only (global)
-- Feature-owned keys live in their modules (e.g., code_intelligence for LSP/Tagbar)
-- Convention: feature modules set buffer-local maps via on_attach / FileType

-- Basic movement and navigation
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Window management
vim.keymap.set('n', '<leader>wv', '<C-w>v')
vim.keymap.set('n', '<leader>ws', '<C-w>s')
vim.keymap.set('n', '<leader>wq', '<C-w>q')
vim.keymap.set('n', '<leader>wo', '<C-w>o')

-- Quick save and quit
vim.keymap.set('n', '<leader>w', ':update<CR>')
vim.keymap.set('n', '<leader>q', ':confirm quit<CR>')
vim.keymap.set('n', '<leader>x', ':confirm bdelete<CR>')

-- Buffer and tab navigation
vim.keymap.set('n', ']b', ':bnext<CR>')
vim.keymap.set('n', '[b', ':bprevious<CR>')
vim.keymap.set('n', ']t', ':tabnext<CR>')
vim.keymap.set('n', '[t', ':tabprevious<CR>')

-- Search improvements
vim.keymap.set('n', '<leader>/', ':nohlsearch<CR>')
vim.keymap.set('n', '*', '*zz')
vim.keymap.set('n', '#', '#zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- Insert mode improvements
vim.keymap.set('i', 'jj', '<ESC>')
vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')

-- Visual mode improvements
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '<leader>y', '"+y')

-- Command mode
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')

-- Terminal mode
vim.keymap.set('t', '<ESC><ESC>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l')
