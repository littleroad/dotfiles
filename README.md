# dotfiles

Personal configuration files for Arch Linux.

## What's included

| File | Target | Description |
|------|--------|-------------|
| `zshrc` | `~/.zshrc` | ZSH config with fast startup (~35ms), emacs keybindings, git aliases, zoxide, fzf |
| `vimrc` | `~/.vimrc` | Vim config with LSP (clangd), vim-go, C/Python indent settings |
| `tmux.conf` | `~/.tmux.conf` | Tmux config with Alt-a prefix, vim navigation, 50K scrollback |
| `alacritty.toml` | `~/.config/alacritty/alacritty.toml` | Alacritty terminal with JetBrainsMono Nerd Font, 80% opacity |
| `gitconfig.template` | `~/.gitconfig` | Git defaults (append to existing config) |
| `nvim/` | `~/.config/nvim/` | Neovim config for C/C++ kernel development (clangd, treesitter, telescope, cscope) |

## Install

```bash
# Preview what would be done
./install.sh --check --pacman

# Apply changes (Arch Linux)
./install.sh --apply --pacman

# Apply changes (Ubuntu/Debian)
./install.sh --apply --apt
```

The installer will:
- Symlink configs to their target locations (backs up existing files)
- Install dependencies (bat, eza, fd, zoxide, neovim, tmux, fzf)
- Install JetBrainsMono Nerd Font

## Dependencies

Core tools used by these configs:

- [bat](https://github.com/sharkdp/bat) — `cat` replacement
- [eza](https://github.com/eza-community/eza) — `ls` replacement
- [fd](https://github.com/sharkdp/fd) — `find` replacement
- [zoxide](https://github.com/ajeetdsouza/zoxide) — smart `cd`
- [neovim](https://neovim.io/) — editor
- [tmux](https://github.com/tmux/tmux) — terminal multiplexer
- [fzf](https://github.com/junegunn/fzf) — fuzzy finder
- [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter) — treesitter parser compiler (for nvim treesitter)
