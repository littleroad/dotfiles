# ============================================================================
# ZSH Configuration - Optimized for fast startup (~30ms)
# ============================================================================

# ---- ZSH Options -----------------------------------------------------------
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # push directories on stack
setopt PUSHD_IGNORE_DUPS    # no duplicate directories
setopt PUSHD_SILENT         # don't print directory stack
setopt HIST_IGNORE_DUPS     # ignore duplicate history entries
setopt HIST_IGNORE_SPACE    # ignore commands starting with space
setopt HIST_VERIFY          # show before executing history
setopt SHARE_HISTORY        # share history between sessions
setopt EXTENDED_HISTORY     # save timestamps
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt COMPLETE_IN_WORD     # complete from cursor position
setopt ALWAYS_TO_END        # move cursor to end on completion
setopt AUTO_MENU            # show completion menu on successive Tab
setopt INTERACTIVE_COMMENTS # allow # comments in interactive shell
setopt MULTIOS              # enable redirect to multiple streams
setopt LONG_LIST_JOBS       # show long format job notifications
setopt PUSHD_MINUS          # enable cd -2 style stack navigation
setopt PUSHD_TO_HOME        # pushd with no args = pushd $HOME
setopt HIST_IGNORE_ALL_DUPS # delete old duplicate history entries
setopt HIST_REDUCE_BLANKS   # trim whitespace before recording
setopt AUTO_LIST            # list completions on ambiguous match
setopt AUTO_PARAM_SLASH     # add trailing slash to completed dirs
setopt NO_BEEP              # no beep on error
setopt NUMERIC_GLOB_SORT    # sort glob matches numerically
setopt EXTENDED_GLOB        # needed for (#q...) glob qualifiers
unsetopt FLOWCONTROL        # disable Ctrl+S/Ctrl+Q freeze

# ---- Word Characters --------------------------------------------------------
# Empty = only alphanumeric are "word" chars, so Ctrl+W stops at / - _ . etc.
WORDCHARS=''

# ---- History ---------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
HIST_STAMPS="yyyy-mm-dd"       # history command output timestamp format
COMPLETION_WAITING_DOTS="true" # show dots while completion is running

# ---- Completion ------------------------------------------------------------
# Cache completion to speed up startup
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh_cache"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z_-}={A-Za-z-_}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# Default LS_COLORS fallback
(( ${+LS_COLORS} )) || typeset -g LS_COLORS='di=1;34:ln=36:pi=40;33:so=1;35:bd=40;33;01:cd=40;33;01:or=1;31:mi=1;31:ex=1;32:*.tar=1;31:*.tgz=1;31:*.zip=1;31:*.gz=1;31:*.bz2=1;31:*.xz=1;31:*.deb=1;31:*.rpm=1;31:*.jar=1;31:*.rar=1;31:*.7z=1;31:*.jpg=1;35:*.jpeg=1;35:*.png=1;35:*.gif=1;35:*.bmp=1;35:*.svg=1;35:*.mov=1;35:*.mp4=1;35:*.mkv=1;35:*.webm=1;35:*.avi=1;35:*.mp3=1;36:*.wav=1;36:*.flac=1;36:*.ogg=1;36:*.aac=1;36:*~=90:*#=90:*.bak=90:*.old=90:*.orig=90:*.swp=90:*.tmp=90'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*' special-dirs true  # complete . and ..

# Create cache dir if needed
[[ -d "$HOME/.zsh_cache" ]] || mkdir -p "$HOME/.zsh_cache"

# Load compinit with caching (much faster)
autoload -Uz compinit
# Full compinit if: dump missing, .zshrc changed, or dump >24h old
if [[ ! -f "$HOME/.zcompdump" ]] || [[ "$HOME/.zshrc" -nt "$HOME/.zcompdump" ]] || [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Bash completion compatibility (for tools that need it)
autoload -U +X bashcompinit && bashcompinit

# ---- Key Bindings ----------------------------------------------------------
bindkey -e  # emacs mode
bindkey '^R' history-incremental-search-backward
bindkey '^[[A' history-beginning-search-backward  # Up arrow
bindkey '^[[B' history-beginning-search-forward   # Down arrow
bindkey ' '  magic-space                          # Space = history expansion
bindkey '^[[1;5C' forward-word                    # Ctrl+Right = forward word
bindkey '^[[1;5D' backward-word                   # Ctrl+Left = backward word
bindkey '^[[3;5~' kill-word                       # Ctrl+Delete = forward delete
bindkey '\C-x\C-e' edit-command-line              # Ctrl+X Ctrl+E = edit in $EDITOR
bindkey '^[[Z' reverse-menu-complete              # Shift+Tab = previous completion

# Ctrl+Z on empty line resumes last suspended job
fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# ---- Colors & Prompt -------------------------------------------------------
autoload -Uz colors && colors
autoload -Uz add-zsh-hook
autoload -Uz vcs_info

# robbyrussell-style prompt (without Oh My Zsh)
# Note: Uses $fg_bold[blue] (color only), NOT %B (bold text attribute)
# The arrow uses %B for bold; git info does not
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr ' %F{yellow}✗%f'
zstyle ':vcs_info:git:*' formats "%F{blue}git:(%f%F{red}%b%f%F{blue})%f%u "
zstyle ':vcs_info:git:*' actionformats "%F{blue}git:(%f%F{red}%b|%a%f%F{blue})%f%u "

_zsh_precmd() {
  vcs_info
}
add-zsh-hook precmd _zsh_precmd

setopt PROMPT_SUBST
PROMPT='%B%(?:%F{green}➜%f :%F{red}➜%f )%F{cyan}%c%f ${vcs_info_msg_0_}%b'

# ---- Terminal Title ------------------------------------------------------
_zsh_termsupport_precmd() {
  [[ $TERM == *(xterm|screen|tmux|alacritty|kitty)* ]] || return
  local pwd="${PWD/#$HOME/~}"
  print -Pn "\e]0;%n@%m: $pwd\a"
}
_zsh_termsupport_preexec() {
  [[ $TERM == *(xterm|screen|tmux|alacritty|kitty)* ]] || return
  local -a cmd; cmd=(${(z)1})
  print -Pn "\e]0;%n@%m: ${cmd[1]:t}\a"
}
add-zsh-hook precmd _zsh_termsupport_precmd
add-zsh-hook preexec _zsh_termsupport_preexec

# ---- PATH ------------------------------------------------------------------
typeset -U path  # unique paths only
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.bun/bin"
  $path
)

# ---- Environment -----------------------------------------------------------
export EDITOR=nvim
export LIBVIRT_DEFAULT_URI='qemu:///system'
[[ -z "$GREP_COLOR" && -z "$GREP_COLORS" ]] && export GREP_COLOR='1;32'  # grep match color

# ---- Aliases ---------------------------------------------------------------
alias vi=nvim
alias vim=nvim
alias vimdiff="nvim -d"
alias sudo='sudo -E'
alias open='gio open'
alias cat='bat --paging=never'
alias ls='eza'
alias ll='eza -la --git'
alias find='fd'
alias wget='wget --content-disposition'
alias iftop='iftop -B -n -N'
alias dd='dd status=progress'
alias axel='axel -a -n 4%'
alias ping='ping -O'
alias df='df --exclude-type=tmpfs'
alias iostat='iostat -Nh'

# directory navigation
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'
alias md='mkdir -p'
alias rd=rmdir
alias d='dirs -v | head -10'   # show directory stack

# tmux
alias tl='tmux list-sessions'
alias ts='tmux new-session -s'
alias ta='tmux attach -t'
alias td='tmux detach -s'

# git aliases
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gau='git add --update'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcam='git commit -a -m'
alias gcb='git checkout -b'
alias gcm='git checkout $(git_main_branch 2>/dev/null || echo master)'
alias gcd='git checkout $(git_develop_branch 2>/dev/null || echo develop)'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gl='git pull --rebase'
alias gpr='git pull --rebase'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpf!='git push --force'
alias gpoat='git push origin --all && git push origin --tags'
alias gpod='git push origin --delete'
alias gd='git diff'
alias gdca='git diff --cached'
alias gds='git diff --staged'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdup='git diff @{upstream}'
alias glog='git log --oneline -20'
alias gloga='git log --oneline --decorate --graph --all'
alias glo='git log --oneline --decorate'
alias glg='git log --stat'
alias glgp='git log --stat -p'
alias gm='git merge'
alias gma='git merge --abort'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbm='git rebase $(git_main_branch 2>/dev/null || echo master)'
alias grbo='git rebase origin/$(git_main_branch 2>/dev/null || echo master)'
alias grh='git reset'
alias grhh='git reset --hard'
alias grm='git rm'
alias grmc='git rm --cached'
alias gst='git status'
alias gsta='git stash push'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gstd='git stash drop'
alias gstaa='git stash apply'
alias gsw='git switch'
alias gswc='git switch -c'
alias gswm='git switch $(git_main_branch 2>/dev/null || echo master)'
alias gswd='git switch $(git_develop_branch 2>/dev/null || echo develop)'
alias gclean='git clean -id'
alias gpristine='git reset --hard && git clean -dfx'
alias gwip='git commit -a -m "WIP"'
alias gunwip='git log -n 1 | grep -q -c "WIP" && git reset HEAD~1'

# ---- Functions ------------------------------------------------------------

# take: mkdir + cd
take() {
  mkdir -p -- "$1"
  cd -- "$1"
}

# Default git branch detection
git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return 1
  local branch
  # 1. current branch if it's main/master
  branch="$(command git symbolic-ref --short HEAD 2>/dev/null)"
  if [[ -n $branch && ( $branch == main || $branch == master ) ]]; then
    echo "$branch"; return 0
  fi
  # 2. origin/HEAD if it's main/master
  branch="$(command git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)"
  branch="${branch#origin/}"
  if [[ -n $branch && ( $branch == main || $branch == master ) ]]; then
    echo "$branch"; return 0
  fi
  # 3. configured default branch (init.defaultBranch)
  branch="$(command git config --get init.defaultBranch 2>/dev/null)"
  [[ -n $branch ]] && { echo "$branch"; return 0; }
  echo master
}
git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return 1
  local branch="$(command git symbolic-ref --short HEAD 2>/dev/null)"
  [[ $branch == develop || $branch == development ]] && { echo "$branch"; return 0; }
  command git show-ref --verify --quiet refs/remotes/origin/develop && { echo develop; return 0; }
  command git show-ref --verify --quiet refs/remotes/origin/development && { echo development; return 0; }
  command git show-ref --verify --quiet refs/heads/develop && { echo develop; return 0; }
  command git show-ref --verify --quiet refs/heads/development && { echo development; return 0; }
  echo develop
}

# Clipboard helpers
if (( $+commands[wl-copy] )); then
  copy()  { if (( $# )); then printf '%s' "$*" | wl-copy; else wl-copy; fi }
  paste() { wl-paste --no-newline; }
  copypath() { printf '%s' "$PWD" | wl-copy; }
  copyfile() { wl-copy < "$1"; }
elif (( $+commands[xclip] )); then
  copy()  { if (( $# )); then printf '%s' "$*" | xclip -selection clipboard; else xclip -selection clipboard; fi }
  paste() { xclip -selection clipboard -o; }
  copypath() { printf '%s' "$PWD" | xclip -selection clipboard; }
  copyfile() { xclip -selection clipboard -in "$1"; }
fi

# zoxide - smart cd (https://github.com/ajeetdsouza/zoxide)
eval "$(zoxide init zsh --cmd z)"

# ---- Lazy Loaders (major startup time savers) -------------------------------

# Lazy-load nvm (saves ~370ms at startup)
# nvm, node, npm, npx, yarn, pnpm will auto-load nvm on first use
_nvm_lazy_load() {
  unset -f nvm node npm npx yarn pnpm _nvm_lazy_load
  export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/share/nvm/init-nvm.sh" ] && source "/usr/share/nvm/init-nvm.sh"
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
}
nvm() { _nvm_lazy_load; nvm "$@"; }
node() { _nvm_lazy_load; node "$@"; }
npm() { _nvm_lazy_load; npm "$@"; }
npx() { _nvm_lazy_load; npx "$@"; }
yarn() { _nvm_lazy_load; yarn "$@"; }
pnpm() { _nvm_lazy_load; pnpm "$@"; }

# ---- FZF Integration (if installed) ----------------------------------------
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  # fzf completion.zsh tries to save/restore 'zle' option which fails in -c mode
  setopt no_zle 2>/dev/null
  source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  setopt zle 2>/dev/null || :
fi

# ---- Local / Private Config ------------------------------------------------
[[ -f "$HOME/.passrc" ]] && source "$HOME/.passrc" || true
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local" || true
