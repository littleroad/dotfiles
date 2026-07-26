-- Treesitter Module
-- Owns: syntax highlighting, folds, text objects
-- Activation: immediate (global)

local M = {}

--- Packer plugin pins (called by plugins.lua thin aggregator)
function M.pack(use)
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }
end

--- Setup treesitter with C/C++ focus
function M.setup()
  local ok, configs = pcall(require, 'nvim-treesitter.configs')
  if not ok then return end

  configs.setup({
    ensure_installed = {
      'c', 'cpp', 'lua', 'vim', 'vimdoc', 'bash',
      'python', 'rust', 'go', 'java',
      'markdown', 'markdown_inline',
    },
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<CR>',
        node_incremental = '<CR>',
        scope_incremental = '<S-CR>',
        node_decremental = '<BS>',
      },
    },
  })

  -- Use treesitter for folds (faster than LSP foldexpr)
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
  vim.opt.foldenable = false
end

return M
