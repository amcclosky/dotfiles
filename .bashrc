#!/bin/bash

alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])"'

alias show-hidden='defaults write com.apple.finder AppleShowAllFiles -boolean true ; killall Finder'
alias hide-hidden='defaults write com.apple.finder AppleShowAllFiles -boolean false ; killall Finder'

alias flushdns='sudo discoveryutil udnsflushcaches'

alias serve='python -m SimpleHTTPServer 8080'

alias ls='ls -lah'

export HISTFILESIZE=1000000
export HISTSIZE=1000000
export HISTCONTROL=ignoreboth
export HISTIGNORE='ls:bg:fg:history'
export HISTTIMEFORMAT='%F %T '

export PROMPT_COMMAND='history -a'

alias dc='docker-compose'
alias cleanup_volumes='docker volume rm $(docker volume ls -f dangling=true -q)'

alias https='http --default-scheme https'

export PATH="~/.dotfiles/bin:$PATH"
export PATH="~/.local/bin:$PATH"
export PATH="/usr/local/opt/openssl/bin:$PATH"

source ./compiler_flags

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
