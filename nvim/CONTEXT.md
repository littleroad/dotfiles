# Context

## What

Neovim config for Linux kernel/C/C++ development. ~272 lines of hand-written Lua.

## Structure

```
init.lua                        # Bootstrap: disable builtins, require order
lua/
├── plugins.lua                 # Thin packer aggregator (chrome only)
└── config/
    ├── basic.lua               # Editor options, leader, builtins
    ├── mappings.lua            # Global keymaps (editor chrome)
    └── code_intelligence.lua   # LSP, cscope, ctags, Tagbar
```

## Load Order

1. `config.basic` — options, leader, disabled builtins
2. `config.mappings` — global keymaps
3. `plugins` — packer pins, calls `code_intelligence.pack(use)`
4. `config.code_intelligence` — calls `setup()` for FileType activation

## Keymap Convention

- **Global keys** (editor chrome) → `mappings.lua`
- **Feature keys** (buffer-local) → their module via `on_attach` / `FileType`
- Example: LSP maps (`gd`, `gr`, `K`) live in `code_intelligence.lua`

## Adding New Features

1. Create `lua/config/<feature>.lua`
2. Export `pack(use)` for plugin pins, `setup()` for activation
3. Add `feature.pack(use)` to `plugins.lua`
4. Add `require('config.<feature>').setup()` to `init.lua`
5. Feature-owned keymaps go in the feature module, not `mappings.lua`

## Domain Vocabulary

- **code_intelligence** — LSP (clangd), cscope, ctags, Tagbar outline
- **chrome** — editor UI (colorscheme, statusline, window nav)
- **thin aggregator** — `plugins.lua` pattern: pins live here, setup lives in feature modules
- **FileType activation** — feature modules activate on specific filetypes, not timers
