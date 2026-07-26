-- Telescope Module
-- Owns: fuzzy finding (files, grep, buffers, git)
-- Activation: immediate (global keymaps)

local M = {}

--- Packer plugin pins (called by plugins.lua thin aggregator)
function M.pack(use)
  use {
    'nvim-telescope/telescope.nvim',

    requires = { 'nvim-lua/plenary.nvim' },
  }
end

--- Setup telescope with keymaps
function M.setup()
  local ok, telescope = pcall(require, 'telescope')
  if not ok then return end

  local actions = require('telescope.actions')

  telescope.setup({
    defaults = {
      file_ignore_patterns = { 'node_modules', '.git/' },
      mappings = {
        i = {
          ['<C-j>'] = actions.move_selection_next,
          ['<C-k>'] = actions.move_selection_previous,
          ['<Esc>'] = actions.close,
        },
      },
    },
    pickers = {
      find_files = { theme = 'dropdown' },
      live_grep = { theme = 'dropdown' },
      buffers = { theme = 'dropdown' },
    },
  })

  local builtin = require('telescope.builtin')
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { desc = 'Telescope: ' .. desc })
  end

  map('<leader>ff', builtin.find_files, 'Find Files')
  map('<leader>fg', builtin.live_grep, 'Live Grep')
  map('<leader>fb', builtin.buffers, 'Buffers')
  map('<leader>fh', builtin.help_tags, 'Help Tags')
  map('<leader>fr', builtin.oldfiles, 'Recent Files')
  map('<leader>gc', builtin.git_commits, 'Git Commits')
  map('<leader>gs', builtin.git_status, 'Git Status')
end

return M
