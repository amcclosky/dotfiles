#!/bin/bash
export BASH_SILENCE_DEPRECATION_WARNING=1

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

export PATH="${DOTROOT}/bin:$PATH"

if [ -f ${DOTROOT}/bin/fancy_prompt.sh ]; then
    source ${DOTROOT}/bin/fancy_prompt.sh
fi

source ${DOTROOT}/vscode/.alias
