#!/bin/bash

DOTROOT="${HOME}/.dotfiles"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export HISTFILESIZE=1000000
export HISTSIZE=1000000
export HISTCONTROL=ignoreboth
export HISTIGNORE='ls:bg:fg:history'
export HISTTIMEFORMAT='%F %T '

export PROMPT_COMMAND='history -a'

export VIRTUAL_ENV_DISABLE_PROMPT=1

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

export PATH="${DOTROOT}/bin:$PATH"
export PATH="/usr/local/opt/openssl/bin:$PATH"

source ${DOTROOT}/.compiler_flags

if command -v pyenv 1> /dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

if command -v pyenv virtualenv 1> /dev/null 2>&1; then
  eval "$(pyenv virtualenv-init -)"
fi

export PATH="~/.poetry/bin:$PATH"
export PATH="~/.local/bin:~/bin:$PATH"

if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi

if [ -f ${DOTROOT}/bin/fancy_prompt.sh ]; then
    source ${DOTROOT}/bin/fancy_prompt.sh
fi

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"

eval "$(direnv hook bash)"

source ${DOTROOT}/.alias
source ${DOTROOT}/.dockeralias
