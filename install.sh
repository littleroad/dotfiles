#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Dotfiles Installer
# Usage: install.sh [--check|--apply] [--pacman|--apt]
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d-%H%M%S)"

# ---- Defaults ----------------------------------------------------------------
MODE="apply"
PKG_MANAGER=""

# ---- Colors ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---- Helpers -----------------------------------------------------------------
info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
create() { echo -e "${GREEN}[CREATE]${NC} $*"; }
backup() { echo -e "${YELLOW}[BACKUP]${NC} $*"; }
install() { echo -e "${CYAN}[INSTALL]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; exit 1; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --check     Dry run: show what would be done without making changes
  --apply     Apply changes (default)
  --pacman    Use pacman for package installation (Arch Linux)
  --apt       Use apt for package installation (Debian/Ubuntu)
  -h, --help  Show this help message

Examples:
  $(basename "$0") --check --pacman    # Preview on Arch
  $(basename "$0") --apply --apt       # Install on Ubuntu
EOF
    exit 0
}

# ---- Parse args --------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --check)  MODE="check"; shift ;;
        --apply)  MODE="apply"; shift ;;
        --pacman) PKG_MANAGER="pacman"; shift ;;
        --apt)    PKG_MANAGER="apt"; shift ;;
        -h|--help) usage ;;
        *) fail "Unknown option: $1" ;;
    esac
done

if [[ -z "$PKG_MANAGER" ]]; then
    fail "Package manager required: --pacman or --apt"
fi

# ---- Config mapping (source -> target) ---------------------------------------
# Format: "source:target_path" (file or dir, kind auto-detected)
LINK_CONFIGS=(
    "zshrc:$HOME/.zshrc"
    "vimrc:$HOME/.vimrc"
    "tmux.conf:$HOME/.tmux.conf"
    "alacritty.toml:$HOME/.config/alacritty/alacritty.toml"
    "gitconfig.template:$HOME/.gitconfig"
    "nvim:$HOME/.config/nvim"
    "awesome:$HOME/.config/awesome"
)

# ---- Dependencies by package manager -----------------------------------------
DEPS_PACMAN=(
    "bat"
    "eza"
    "fd"
    "zoxide"
    "neovim"
    "tmux"
    "fzf"
)

DEPS_APT=(
    "bat"
    "eza"
    "fd-find"
    "zoxide"
    "neovim"
    "tmux"
    "fzf"
)

FONT_PKG_PACMAN="ttf-jetbrains-mono-nerd"
FONT_PKG_APT=""  # No standard apt package; would need manual install

# ---- Functions ---------------------------------------------------------------
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        if [[ "$MODE" == "apply" ]]; then
            mkdir -p "$dir"
        fi
        create "$dir"
    else
        ok "$dir exists"
    fi
}

link_config() {
    local src="$1"
    local dst="$2"
    local src_full="$DOTFILES_DIR/$src"

    if [[ ! -e "$src_full" ]]; then
        warn "Source not found: $src_full"
        return
    fi

    if [[ -L "$dst" ]]; then
        local current_target
        current_target="$(readlink "$dst")"
        if [[ "$current_target" == "$src_full" ]]; then
            ok "$dst -> $src (already linked)"
            return
        fi
        # Different target, backup and replace
        if [[ "$MODE" == "apply" ]]; then
            ensure_dir "$BACKUP_DIR"
            mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
            backup "$dst -> $BACKUP_DIR/$(basename "$dst")"
            ln -sf "$src_full" "$dst"
        else
            backup "$dst (would backup, different target)"
        fi
    elif [[ -e "$dst" ]]; then
        # Target exists, not a symlink
        if [[ "$MODE" == "apply" ]]; then
            ensure_dir "$BACKUP_DIR"
            mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
            backup "$dst -> $BACKUP_DIR/$(basename "$dst")"
            ln -sf "$src_full" "$dst"
        else
            backup "$dst (would backup)"
        fi
    else
        # No target exists, just symlink
        if [[ "$MODE" == "apply" ]]; then
            ensure_dir "$(dirname "$dst")"
            ln -sf "$src_full" "$dst"
        fi
        create "$dst -> $src"
    fi
}

install_deps() {
    local deps=()
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        deps=("${DEPS_PACMAN[@]}")
    else
        deps=("${DEPS_APT[@]}")
    fi

    info "Checking dependencies..."
    for pkg in "${deps[@]}"; do
        # Check if command exists (handle package -> command name mappings)
        local cmd="$pkg"
        [[ "$pkg" == "fd-find" ]] && cmd="fdfind"
        [[ "$pkg" == "fd" ]] && cmd="fd"
        [[ "$pkg" == "neovim" ]] && cmd="nvim"

        if command -v "$cmd" &>/dev/null || (command -v fdfind &>/dev/null && [[ "$pkg" == "fd" ]]); then
            ok "$pkg (installed)"
        else
            if [[ "$MODE" == "apply" ]]; then
                install "$pkg"
                if [[ "$PKG_MANAGER" == "pacman" ]]; then
                    sudo pacman -S --noconfirm "$pkg" 2>/dev/null || warn "Failed to install $pkg"
                else
                    sudo apt install -y "$pkg" 2>/dev/null || warn "Failed to install $pkg"
                fi
            else
                install "$pkg (would install)"
            fi
        fi
    done
}

install_font() {
    local font_pkg
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        font_pkg="$FONT_PKG_PACMAN"
    else
        font_pkg="$FONT_PKG_APT"
    fi

    if [[ -z "$font_pkg" ]]; then
        warn "No font package available for $PKG_MANAGER"
        warn "Install JetBrainsMono Nerd Font manually: https://www.nerdfonts.com/"
        return
    fi

    local fonts
    fonts="$(fc-list 2>/dev/null)"
    if echo "$fonts" | grep -qi "JetBrainsMono.*Nerd Font"; then
        ok "JetBrainsMono Nerd Font (installed)"
    else
        if [[ "$MODE" == "apply" ]]; then
            install "$font_pkg"
            if [[ "$PKG_MANAGER" == "pacman" ]]; then
                sudo pacman -S --noconfirm "$font_pkg" 2>/dev/null || warn "Failed to install font"
            else
                sudo apt install -y "$font_pkg" 2>/dev/null || warn "Failed to install font"
            fi
        else
            install "$font_pkg (would install)"
        fi
    fi
}

# ---- Main --------------------------------------------------------------------
main() {
    echo ""
    info "Dotfiles installer (mode: $MODE, pkg: $PKG_MANAGER)"
    echo ""

    # Symlink configs
    info "Setting up config symlinks..."
    for entry in "${LINK_CONFIGS[@]}"; do
        IFS=':' read -r src dst <<< "$entry"
        link_config "$src" "$dst"
    done

    # Warn about legacy alacritty config
    if [[ -f "$HOME/.alacritty.toml" && ! -L "$HOME/.alacritty.toml" ]]; then
        warn "$HOME/.alacritty.toml exists (legacy path), consider removing"
    fi
    echo ""

    # Install dependencies
    install_deps
    echo ""

    # Install font
    info "Checking fonts..."
    install_font
    echo ""

    # Summary
    if [[ "$MODE" == "check" ]]; then
        info "Dry run complete. Run with --apply to make changes."
    else
        ok "Installation complete!"
        info "Restart your shell or run: source ~/.zshrc"
    fi
}

main
