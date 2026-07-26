-- Neovim Configuration

-- Disable unused built-in plugins for faster startup
local disabled_plugins = {
  "netrwPlugin", "netrwSettings", "netrwFileHandlers",
  "gzip", "zip", "zipPlugin", "tar", "tarPlugin",
  "getscript", "getscriptPlugin", "vimball", "vimballPlugin",
  "2html_plugin", "logipat", "rrhelper", "spellfile_plugin"
}

for _, plugin in ipairs(disabled_plugins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Load essential modules
require('config.basic')
require('config.mappings')
require('plugins')
require('config.code_intelligence').setup()
require('config.treesitter').setup()
require('config.telescope').setup()

