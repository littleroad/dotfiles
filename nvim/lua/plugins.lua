-- Plugin configuration with packer (thin aggregator)
-- Chrome plugins only; feature-owned pins live in their modules.

local code_intelligence = require('config.code_intelligence')
local treesitter = require('config.treesitter')
local telescope = require('config.telescope')

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- colorscheme (pin + setup co-located)
  use 'tomasr/molokai'
  vim.cmd.colorscheme('molokai')
  vim.cmd.highlight('Normal guibg=NONE')
  vim.cmd.highlight('NonText guibg=NONE')
  vim.cmd.highlight('Comment guifg=#808080')

  -- git
  use 'tpope/vim-fugitive'
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          map('n', ']c', function() gs.next_hunk() end, { desc = 'Next git hunk' })
          map('n', '[c', function() gs.prev_hunk() end, { desc = 'Prev git hunk' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview git hunk' })
          map('n', '<leader>gb', gs.blame_line, { desc = 'Blame line' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset git hunk' })
        end,
      })
    end,
  }

  -- which-key (show available keymaps)
  use {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup({ triggers = { "," } })
    end,
  }

  -- Code intelligence plugins (owned by code_intelligence module)
  code_intelligence.pack(use)

  -- Treesitter (owned by treesitter module)
  treesitter.pack(use)

  -- Telescope (owned by telescope module)
  telescope.pack(use)
end)
