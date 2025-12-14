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


# Setup local bin path (pipx uses this)
export PATH="$PATH:$HOME/.local/bin"

export PATH="$PATH:$HOME/.deno/bin"


# Preferred Python defaults
export PIP_DISABLE_PIP_VERSION_CHECK=1
export VIRTUAL_ENV_DISABLE_PROMPT=1


# Setup homebrew
export HOMEBREW_NO_ENV_HINTS=1
if type brew &>/dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'


autoload -Uz compinit && compinit
autoload -Uz promptinit && promptinit
autoload -U +X bashcompinit && bashcompinit

# init terraform cli completion
complete -o nospace -C /opt/homebrew/bin/terraform terraform


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
  [[ -z "$HOST" ]] && HOST="ap-main-pro"
  PROMPT="%B%F{red}%m%f%b %B%F{240}in%f%b %B%F{190}%~%f%b $(git_prompt) $prompt_newline%(!.#.$) "
}


# Configure pre command hooks
precmd_functions+=( set_prompt )

zstyle ':completion:*' menu select
fpath+=~/.zfunc


# PATH customization

# add subl command to the global PATH
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

# Customize EDITOR
export EDITOR='code --wait'

# add Snowflake SnowSQL to macos path
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH

# add amplify-cli
export PATH="$HOME/.amplify/bin:$PATH"

# add mysql-client to macos path
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

# java stuff
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# Source local settings (not in git)
[[ -f ${DOTROOT}/.zshrc.local ]] && source ${DOTROOT}/.zshrc.local

# Setup direnv
eval "$(direnv hook zsh)"

# Setup mise
eval "$(~/.local/bin/mise activate zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

alias cc="DEBUG=0 ~/.local/bin/claude --allow-dangerously-skip-permissions"
