#!/bin/zsh

setopt AUTO_CD
setopt NO_CASE_GLOB

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_NO_STORE

# Setup shell history config
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTORY_IGNORE="(ls|bg|fg)"
SAVEHIST=10000
HISTSIZE=20000


# Add useful aliases
DOTROOT="${HOME}/.dotfiles"
source ${DOTROOT}/.alias

# Setup useful globals
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export CODE_HOME=$HOME/code


# Preferred Python defaults
export PIP_DISABLE_PIP_VERSION_CHECK=1
export VIRTUAL_ENV_DISABLE_PROMPT=1


# Setup homebrew (test the file: brew isn't on PATH until shellenv runs)
export HOMEBREW_NO_ENV_HINTS=1
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

fpath+=~/.zfunc
[[ -d ~/.grok/completions/zsh ]] && fpath=(~/.grok/completions/zsh $fpath)

autoload -Uz compinit && compinit
autoload -Uz promptinit && promptinit
autoload -U +X bashcompinit && bashcompinit


# Customize shell prompt with git metadata
parse_git_dirty () {
  [[ -n $(git status --porcelain 2>/dev/null) ]] && echo "*"
}
parse_git_branch () {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

git_prompt() {
 branch=$(parse_git_branch)
 [[ -n $branch ]] && echo "%B%F{240}on%f%b %B%F{141}$branch%f%b"
}

set_prompt () {
  PROMPT="%B%F{red}%m%f%b %B%F{240}in%f%b %B%F{190}%~%f%b $(git_prompt) $prompt_newline%(!.#.$) "
}


# Configure pre command hooks
precmd_functions+=( set_prompt )

zstyle ':completion:*' menu select


# PATH customization

# Local bin (claude, uv and other standalone installers)
export PATH="$HOME/.local/bin:$PATH"

export PATH="$PATH:$HOME/.deno/bin"

# add subl command to the global PATH
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

# Customize EDITOR
export EDITOR='code --wait'

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun
export PATH="$HOME/.bun/bin:$PATH"

# grok
export PATH="$HOME/.grok/bin:$PATH"

# hubspot
export PATH="$HOME/.hubspot/bin:$PATH"

# Vite+ bin (https://viteplus.dev)
[[ -f "$HOME/.vite-plus/env" ]] && . "$HOME/.vite-plus/env"


# Source local settings (not in git)
[[ -f ${DOTROOT}/.zshrc.local ]] && source ${DOTROOT}/.zshrc.local

# Setup direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Setup fnox
command -v fnox >/dev/null 2>&1 && eval "$(fnox activate zsh)"


alias cc="DEBUG=0 claude --allow-dangerously-skip-permissions"

alias cca="DEBUG=0 ENABLE_CLAUDEAI_MCP_SERVERS=0 CLAUDE_CONFIG_DIR=~/.claude-amcclosky claude --allow-dangerously-skip-permissions"

alias ccb="DEBUG=0 ENABLE_CLAUDEAI_MCP_SERVERS=1 CLAUDE_CONFIG_DIR=~/.claude-backflip claude --allow-dangerously-skip-permissions"

alias ccmc="DEBUG=0 ENABLE_CLAUDEAI_MCP_SERVERS=0 CLAUDE_CONFIG_DIR=~/.claude-mcclosky-dev claude --allow-dangerously-skip-permissions"

# agent-browser remote connect (set RBROWSER_HOST in .zshrc.local)
rbrowser() {
  local host=${RBROWSER_HOST:?set RBROWSER_HOST in ~/.dotfiles/.zshrc.local}
  local ws_url=$(curl -s http://$host:9222/json/version | jq -r .webSocketDebuggerUrl | sed "s|ws://[^:/]*|ws://$host|")
  npx agent-browser connect "$ws_url"
}


# Setup mise (keep last so its tool paths stay ahead of every PATH change above)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
  # terraform comes from mise, so its completion has to wait for activation
  command -v terraform >/dev/null 2>&1 && complete -o nospace -C "$(command -v terraform)" terraform
  command -v wt >/dev/null 2>&1 && eval "$(command wt config shell init zsh 2>/dev/null)"
fi
