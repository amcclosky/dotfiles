# dotfiles

Set up a Mac with [mise bootstrap](https://mise.jdx.dev/bootstrap.html).
`mise.toml` declares everything:

- `[dotfiles]`: the links into `$HOME`
- `[bootstrap.packages]`: Homebrew formulae and casks
- `[bootstrap.macos.*]`: Dock, Finder and other macOS settings. Run
  `mise -C ~/.dotfiles run restart-ui` (or log out) to see them.
- `[tasks.bootstrap]`: installs the VS Code extensions in `vscode/extensions.txt`

Global CLI tools that mise installs itself (node, bun, gcloud, aws, ...) are in
`mise/config.toml`, which is linked as the global mise config.

## Setup

1. Install [Homebrew](https://brew.sh), then mise
    ```
    brew install mise
    ```

1. Clone `dotfiles` (public, so HTTPS needs no credentials)
    ```
    git clone https://github.com/amcclosky/dotfiles ~/.dotfiles
    git -C ~/.dotfiles remote set-url origin git@github.com:amcclosky/dotfiles.git
    ```

1. Bootstrap. This installs the packages, links the dotfiles, installs the
   global mise tools and the VS Code extensions. Preview it with `--dry-run`.
    ```
    mise trust ~/.dotfiles
    mise -C ~/.dotfiles bootstrap
    ```
    | Repo file | Linked as |
    | --- | --- |
    | `.zshrc` | `~/.zshrc` |
    | `.gitconfig` | `~/.gitconfig` |
    | `.gitignore` | `~/.gitignore_global` |
    | `mise/config.toml` | `~/.config/mise/config.toml` |

    A file already at a link's path stops the apply; move it aside, or pass
    `--force` to `mise -C ~/.dotfiles dot apply`.

1. Optionally install the Mac App Store apps (Bear, Xcode) too. They're
   opt-in in `mise.appstore.toml`, and need you signed in to the App Store.
    ```
    mise -C ~/.dotfiles -E appstore bootstrap
    ```
    `mas` has to be on PATH (`eval "$(/opt/homebrew/bin/brew shellenv)"`). If
    the apps show as skipped, run it again.

1. Do these by hand:
    - [ ] Copy `~/.ssh` from the old Mac (needed for the SSH `origin` above
      and for cloning other repos)
    - [ ] Install Rex Beta (no cask), from the [installation docs](https://www.superlogical.com/rex/docs/installation)
      (needs a Discord login)

1. Put machine-specific settings and secrets in `~/.dotfiles/.zshrc.local`
   (gitignored). Machine-specific aliases go in `~/.dotfiles/.alias.local`
   (gitignored), e.g. the `cca`/`ccb`/`ccmc` Claude profile aliases.

## Keeping it up to date

- Add a package: `mise -C ~/.dotfiles bootstrap packages use brew:<name>`, or
  edit `mise.toml`. `mise -C ~/.dotfiles bootstrap packages status` shows what
  differs.
- Add a global tool: `mise use -g <tool>@<version>` (writes `mise/config.toml`).
- Add a VS Code extension: append its id to `vscode/extensions.txt`.
- Installers often append to `~/.zshrc`, which is a link into this public
  repo. Check `git -C ~/.dotfiles diff` after running one, and move anything
  machine-specific into `.zshrc.local`.

## Notes

- `.bashrc`, `.bash_profile` and `vscode/install.sh` are legacy bash config;
  nothing links them by default.
