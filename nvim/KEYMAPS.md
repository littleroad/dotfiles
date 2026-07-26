# Keymaps

Leader key: `,`

## Global (mappings.lua)

| Key | Mode | Action |
|-----|------|--------|
| `j` | n | Move down (visual line) |
| `k` | n | Move up (visual line) |
| `<C-h>` | n | Window left |
| `<C-j>` | n | Window down |
| `<C-k>` | n | Window up |
| `<C-l>` | n | Window right |
| `<leader>wv` | n | Vertical split |
| `<leader>ws` | n | Horizontal split |
| `<leader>wq` | n | Close window |
| `<leader>wo` | n | Close other windows |
| `<leader>w` | n | Save |
| `<leader>q` | n | Quit |
| `<leader>x` | n | Delete buffer |
| `]b` | n | Next buffer |
| `[b` | n | Previous buffer |
| `]t` | n | Next tab |
| `[t` | n | Previous tab |
| `<leader>/` | n | Clear search highlight |
| `*` | n | Search word under cursor (centered) |
| `#` | n | Search word under cursor (centered) |
| `n` | n | Next search result (centered) |
| `N` | n | Previous search result (centered) |
| `jj` | i | Escape |
| `<C-a>` | i | Home |
| `<C-e>` | i | End |
| `<` | v | Indent left (stay in visual) |
| `>` | v | Indent right (stay in visual) |
| `<leader>y` | v | Copy to system clipboard |
| `<C-a>` | c | Home |
| `<C-e>` | c | End |
| `<ESC><ESC>` | t | Exit terminal mode |
| `<C-h>` | t | Window left from terminal |
| `<C-j>` | t | Window down from terminal |
| `<C-k>` | t | Window up from terminal |
| `<C-l>` | t | Window right from terminal |

## Telescope (config/telescope.lua)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Buffers |
| `<leader>fh` | n | Help tags |
| `<leader>fr` | n | Recent files |
| `<leader>gc` | n | Git commits |
| `<leader>gs` | n | Git status |

## Gitsigns (plugins.lua)

| Key | Mode | Action |
|-----|------|--------|
| `]c` | n | Next git hunk |
| `[c` | n | Previous git hunk |
| `<leader>gp` | n | Preview hunk |
| `<leader>gb` | n | Blame line |
| `<leader>gr` | n | Reset hunk |

## LSP (config/code_intelligence.lua)

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition |
| `gr` | n | References |
| `gD` | n | Declaration |
| `gi` | n | Implementation |
| `K` | n | Hover docs |
| `rn` | n | Rename symbol |
| `<leader>ca` | n | Code action |
| `<leader>f` | n, v | Format |
| `[d` | n | Previous diagnostic |
| `]d` | n | Next diagnostic |

## Treesitter (config/treesitter.lua)

| Key | Mode | Action |
|-----|------|--------|
| `<CR>` | n | Expand selection |
| `<CR>` | v | Extend selection |
| `<S-CR>` | v | Scope extend |
| `<BS>` | v | Shrink selection |

## Tagbar (config/code_intelligence.lua)

| Key | Mode | Action |
|-----|------|--------|
| `tt` | n | Toggle Tagbar |

## Cscope (cscope_maps.nvim)

Prefix: `<Leader>c` — see `:help cscope_maps` for full list.
