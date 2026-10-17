# dotfiles

## Setup

1. Install [Homebrew](https://brew.sh), then the GitHub CLI
    ```
    brew install gh
    gh auth login
    ```

1. Clone `dotfiles`
    ```
    gh repo clone amcclosky/dotfiles ~/.dotfiles
    ```

1. Install packages, casks and VS Code extensions
    ```
    cd ~/.dotfiles && brew bundle install
    ```
    Solo isn't a cask; install it by hand.

1. Link the dotfiles into `$HOME` (moves any existing file to `<file>.bak`)
    ```
    ~/.dotfiles/install.sh
    ```
    | Repo file | Linked as |
    | --- | --- |
    | `.zshrc` | `~/.zshrc` |
    | `.gitconfig` | `~/.gitconfig` |
    | `.gitignore` | `~/.gitignore_global` |
    | `mise/config.toml` | `~/.config/mise/config.toml` |

1. Install the global mise tools (node, bun, gcloud, aws, ...)
    ```
    mise install
    ```

1. Put machine-specific settings and secrets in `~/.dotfiles/.zshrc.local`
   (gitignored). Machine-specific
   aliases go in `~/.dotfiles/.alias.local` (gitignored), e.g. the
   `cca`/`ccb`/`ccmc` Claude profile aliases.

## Notes

- Installers often append to `~/.zshrc`, which is a link into this public
  repo. Check `git -C ~/.dotfiles diff` after running one, and move anything
  machine-specific into `.zshrc.local`.
- `.bashrc`, `.bash_profile` and `vscode/` are legacy bash config; nothing
  links them by default.
- Refresh the Brewfile with `brew bundle dump --force --file=~/.dotfiles/Brewfile`.
