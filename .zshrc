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

setopt CORRECT
unsetopt CORRECT

setopt CORRECT_ALL
unsetopt CORRECT_ALL

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTORY_IGNORE="(ls|bg|fg)"
SAVEHIST=10000
HISTSIZE=20000

DOTROOT="${HOME}/.dotfiles"

source ${DOTROOT}/.alias

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export OKTA_USERNAME=anthony.mcclosky

export PIP_DISABLE_PIP_VERSION_CHECK=1
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PATH="$PATH:$HOME/.local/bin"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1> /dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

if command -v pyenv virtualenv 1> /dev/null 2>&1; then
  eval "$(pyenv virtualenv-init -)"
fi

export PATH="$PATH:/usr/local/opt/python/libexec/bin"

export PROJECT_HOME=$HOME/projects

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

autoload -Uz compinit && compinit

autoload -Uz promptinit && promptinit

parse_git_dirty () {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
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

# /start .nvmrc - setup auto nvm use
autoload -U add-zsh-hook

load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc

load-nvmrc

# /end .nvmrc

precmd_functions+=( set_prompt )

autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc

eval "$(direnv hook zsh)"
