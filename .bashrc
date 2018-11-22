#!/bin/bash

export HISTFILESIZE=1000000
export HISTSIZE=1000000
export HISTCONTROL=ignoreboth
export HISTIGNORE='ls:bg:fg:history'
export HISTTIMEFORMAT='%F %T '

export PROMPT_COMMAND='history -a'

export PATH="~/.dotfiles/bin:$PATH"
export PATH="~/.local/bin:$PATH"
export PATH="/usr/local/opt/openssl/bin:$PATH"

source ./compiler_flags
source ./alias

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

if command -v pyenv virtualenv 1>/dev/null 2>&1; then
  eval "$(pyenv virtualenv-init -)"
fi

if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi

if [ -f ~/.dotfiles/bin/fancy_prompt.sh ]; then 
    source ~/.dotfiles/bin/fancy_prompt.sh
fi

eval "$(direnv hook bash)"
