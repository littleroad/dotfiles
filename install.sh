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
EXCLUDES=()

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
  --exclude   Skip a config by source name (may be repeated: --exclude awesome --exclude vimrc)
  --pacman    Use pacman for package installation (Arch Linux)
  --apt       Use apt for package installation (Debian/Ubuntu)
  -h, --help  Show this help message

Examples:
  $(basename "$0") --check --pacman    # Preview on Arch
  $(basename "$0") --apply --apt       # Install on Ubuntu
  $(basename "$0") --apply --pacman --exclude awesome  # Skip awesome WM config
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
        --exclude) EXCLUDES+=("$2"); shift 2 ;;
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
    "hypr:$HOME/.config/hypr"
    "waybar:$HOME/.config/waybar"
    "mako:$HOME/.config/mako"
    "neomutt/neomuttrc:$HOME/.config/neomutt/neomuttrc"
    # Rime 配置（只链配置文件，build/userdb 等运行时数据留在原处）
    "rime/default.custom.yaml:$HOME/.local/share/fcitx5/rime/default.custom.yaml"
    "rime/rime_ice.custom.yaml:$HOME/.local/share/fcitx5/rime/rime_ice.custom.yaml"
    "rime/double_pinyin_flypy.custom.yaml:$HOME/.local/share/fcitx5/rime/double_pinyin_flypy.custom.yaml"
    "rime/rime.lua:$HOME/.local/share/fcitx5/rime/rime.lua"
    "rime/lua/flypy_hint.lua:$HOME/.local/share/fcitx5/rime/lua/flypy_hint.lua"
)

# ---- Dependencies (neutral names; per-manager mapping below) -----------------
DEPS=(
    "bat"
    "eza"
    "fd"
    "zoxide"
    "neovim"
    "tmux"
    "fzf"
    "hyprland"
    "waybar"
    "mako"
    "grim"
    "slurp"
    "swaybg"
    "swaylock"
    "wofi"
    "wl-clipboard"
)

# ---- Package manager adapters ------------------------------------------------
# One seam, two adapters. Callers use neutral names; package/command names are
# resolved per manager here.
case "$PKG_MANAGER" in
    pacman)
        PKG_INSTALL=(sudo pacman -S --noconfirm)
        pkg_package_name() {
            case "$1" in
                nerd-font) echo "ttf-jetbrains-mono-nerd" ;;
                *) echo "$1" ;;
            esac
        }
        pkg_command_name() {
            case "$1" in
                neovim) echo nvim ;;
                *) echo "$1" ;;
            esac
        }
        ;;
    apt)
        PKG_INSTALL=(sudo apt install -y)
        pkg_package_name() {
            case "$1" in
                fd) echo fd-find ;;
                nerd-font) echo "" ;;
                *) echo "$1" ;;
            esac
        }
        pkg_command_name() {
            case "$1" in
                fd) echo fdfind ;;
                neovim) echo nvim ;;
                *) echo "$1" ;;
            esac
        }
        ;;
esac

pkg_available() {
    command -v "$(pkg_command_name "$1")" &>/dev/null
}

pkg_install() {
    "${PKG_INSTALL[@]}" "$(pkg_package_name "$1")" 2>/dev/null
}

pkg_font_pkg() {
    pkg_package_name nerd-font
}

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
    info "Checking dependencies..."
    for pkg in "${DEPS[@]}"; do
        if pkg_available "$pkg"; then
            ok "$pkg (installed)"
        else
            if [[ "$MODE" == "apply" ]]; then
                install "$(pkg_package_name "$pkg")"
                pkg_install "$pkg" || warn "Failed to install $pkg"
            else
                install "$(pkg_package_name "$pkg") (would install)"
            fi
        fi
    done
}

install_font() {
    local font_pkg
    font_pkg="$(pkg_font_pkg)"

    if [[ -z "$font_pkg" ]]; then
        warn "No font package available for $PKG_MANAGER"
        warn "Install JetBrainsMono Nerd Font manually: https://www.nerdfonts.com/"
        return
    fi

    local fonts
    fonts="$(fc-list 2>/dev/null || true)"
    if echo "$fonts" | grep -qi "JetBrainsMono.*Nerd Font"; then
        ok "JetBrainsMono Nerd Font (installed)"
    else
        if [[ "$MODE" == "apply" ]]; then
            install "$font_pkg"
            pkg_install nerd-font || warn "Failed to install font"
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
        # Skip if excluded by --exclude
        local skip=false
        for x in "${EXCLUDES[@]}"; do
            if [[ "$src" == "$x" ]]; then
                skip=true
                break
            fi
        done
        $skip && continue
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
