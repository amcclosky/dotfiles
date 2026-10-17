# dotfiles

Set up a Mac with [mise bootstrap](https://mise.jdx.dev/bootstrap.html).
`mise.toml` declares everything:

- `[dotfiles]`: the links into `$HOME`
- `[bootstrap.packages]`: Homebrew formulae and casks
- `[bootstrap.macos.*]`: Dock, Finder and other macOS settings. Run
  `mise -C ~/.dotfiles run restart-ui` (or log out) to see them.
- `[tasks.bootstrap]`: runs `install-claude` (the Claude Code native
  installer, skipped if `~/.local/bin/claude` exists) and `clone-repos`, then
  installs the VS Code extensions in `vscode/extensions.txt`
- `fnox.toml`: `CODE_REPOS`, the repos `clone-repos` clones into `~/code`.
  It's age-encrypted to `~/.ssh/id_ed25519`, since this repo is public.

Global CLI tools that mise installs itself (node, bun, codex, gcloud, aws,
...) are in `mise/config.toml`, which is linked as the global mise config.

## Setup

1. Install [Homebrew](https://brew.sh) (the packages are Homebrew formulae and
   casks).

1. Clone `dotfiles` (public, so HTTPS needs no credentials)
    ```
    git clone https://github.com/amcclosky/dotfiles ~/.dotfiles
    git -C ~/.dotfiles remote set-url origin git@github.com:amcclosky/dotfiles.git
    ```

1. Copy `~/.ssh` and the `~/.config/fnox/*.txt` age keys from the old Mac.
    - `~/.ssh`: bootstrap needs it to decrypt the repo list and clone the
      repos; without it, `clone-repos` skips them (run
      `mise -C ~/.dotfiles run clone-repos` later).
    - `~/.config/fnox/age.txt`: the age key that fnox uses to decrypt
      secrets in projects whose `fnox.toml` is encrypted to it.
    - `~/.config/fnox/amp-orb-age.txt`: a second age key.

    Keep the age keys `chmod 600`.

1. Bootstrap. This installs the packages, links the dotfiles, installs the
   global mise tools (including Codex) and Claude Code, clones the `~/code`
   repos, and installs the VS Code extensions. Preview it with `--dry-run`.
    ```
    ~/.dotfiles/bin/mise trust ~/.dotfiles
    ~/.dotfiles/bin/mise -C ~/.dotfiles bootstrap
    ```
    `bin/mise` downloads a pinned mise on first run, so mise doesn't need to be
    installed yet. Bootstrap installs mise from Homebrew (`brew:mise`); open a
    new terminal afterwards and use plain `mise` from then on.

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
- Change the repo list: `fnox get CODE_REPOS > list`, edit it, then
  `cat list | fnox set CODE_REPOS -p age` (from `~/.dotfiles`).
- Installers often append to `~/.zshrc`, which is a link into this public
  repo. Check `git -C ~/.dotfiles diff` after running one, and move anything
  machine-specific into `.zshrc.local`.
- Update the mise version that `bin/mise` pins:
  `mise generate install-script --write ~/.dotfiles/bin/mise`.

## Notes

- `.bashrc`, `.bash_profile` and `vscode/install.sh` are legacy bash config;
  nothing links them by default.
