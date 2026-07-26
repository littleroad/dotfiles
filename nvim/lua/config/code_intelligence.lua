-- Code Intelligence Module
-- Owns: LSP (clangd), cscope, ctags, Tagbar outline
-- Activation: FileType (c/cpp family)
-- Backend: layered coexistence (clangd semantic, cscope/tags index fallback)

local M = {}

--- Packer plugin pins (called by plugins.lua thin aggregator)
function M.pack(use)
  use 'preservim/tagbar'
  use 'dhananjaylatkar/cscope_maps.nvim'
  -- nvim-lspconfig dropped - using native vim.lsp.config (Neovim 0.12+)
end

--- Setup clangd LSP via native API
local function setup_clangd()
  if vim.fn.executable('clangd') ~= 1 then
    return
  end

  vim.lsp.config('clangd', {
    cmd = { 'clangd', '--header-insertion=never' },
    on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }

      -- Jump stack (LSP)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

      -- Info
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

      -- Refactor
      vim.keymap.set('n', 'rn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

      -- Format
      vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
        vim.lsp.buf.format({ async = true })
      end, opts)

      -- Diagnostics navigation
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    end,
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  })

  vim.lsp.enable('clangd')

  -- Enable completion on attach
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client:supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
      end
    end,
  })
end

--- Setup cscope/ctags as index fallback
local function setup_index_layer()
  local ok, cscope_maps = pcall(require, 'cscope_maps')
  if ok then
    cscope_maps.setup({
      disable_maps = false,
      skip_input_prompt = false,
      prefix = '<Leader>c',
      db_file = './cscope.out',
      db_root = vim.fn.getcwd(),
    })
    -- cscope_maps handles database addition during setup;
    -- no manual ':Cscope add' needed.
  elseif vim.fn.executable('ctags') == 1 then
    vim.opt.tags = './tags;'
  end
end

--- Setup Tagbar keybinding
local function setup_tagbar()
  vim.keymap.set('n', 'tt', ':TagbarToggle<CR>')
end

--- Main setup: activate on FileType for c/cpp family
function M.setup()
  -- LSP fold (owns the foldexpr that basic.lua cannot)
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
  vim.opt.foldenable = false

  -- Tagbar keybinding (always available if plugin loaded)
  setup_tagbar()

  -- Activate code intelligence on c/cpp filetypes
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c', 'cpp', 'h', 'hpp', 'objc', 'objcpp' },
    callback = function()
      setup_clangd()
      setup_index_layer()
    end,
  })
end

return M
