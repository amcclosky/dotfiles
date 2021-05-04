# dotfiles

## Setup

1. Install `brew`

1. Install GitHub CLI
    ```
    brew install gh
    ```

1. Clone `dotfiles`
    ```
    gh login
    gh repo clone amcclosky/dotfiles .dotfiles
    ```

1. `cd .dotfiles && brew bundle install`

1. Install `nvm` 

1. Link .zshrc to $HOME
    ```
    ln -s ~/.dotfiles/.zshrc ~/.zshrc
    ```
