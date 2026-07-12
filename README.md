# dotfiles

Meine macOS-Umgebung: terminal-nativ, `nvim` + `tmux` + Claude Code, verwaltet
mit [chezmoi](https://chezmoi.io). Ein Skript setzt einen frischen Mac komplett auf.

## Frischer Mac — in drei Zeilen

```sh
xcode-select --install                                   # falls noch nicht da
git clone https://github.com/ur-grue/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./setup.sh
```

`setup.sh` installiert Homebrew + alle Pakete (Brewfile), oh-my-zsh + p10k,
wendet alle Configs via chezmoi an (inkl. Secrets aus `pass`, mise-Runtimes,
tmux-Plugins), setzt macOS-Defaults und klont die aktiven Repos nach `~/dev`.
Danach: **manuelle Restschritte** in [`docs/cheatsheet.md`](docs/cheatsheet.md) → „Nach dem Setup".

## Was drin ist

| Bereich      | Tools |
|--------------|-------|
| Terminal     | Ghostty (Rosé Pine, Hell/Dunkel folgt macOS) |
| Multiplexer  | tmux (+ resurrect/continuum, vim-tmux-navigator) |
| Editor       | Neovim (lazy.nvim, Rosé Pine, Claude Code integriert) |
| KI-Coding    | Claude Code in tmux-Pane + `claudecode.nvim` (Inline-Diffs) |
| Shell        | zsh + oh-my-zsh + Powerlevel10k |
| CLI          | eza, bat, ripgrep, fd, zoxide, fzf, atuin, delta, lazygit, yazi … |
| Runtimes     | mise (node, python, ruby) |
| Notizen      | zk (Zettelkasten), jrnl |
| Lesen        | newsboat (Wissenschaft + KI), w3m |

## Täglicher chezmoi-Workflow (einfach)

```sh
chezmoi edit ~/.zshrc      # Datei über die Repo-Quelle bearbeiten
chezmoi apply              # Änderungen ins $HOME übernehmen
chezmoi cd                 # in die Repo-Quelle wechseln -> git add/commit/push
```

Kurzform: `chezmoi edit` → `chezmoi apply` → committen. Fertig.

## Secrets

Kommen **nie** ins Repo. `~/.config/zsh/secrets.zsh` ist gitignored; nur
`secrets.zsh.example` ist getrackt. Keys optional aus `pass` ziehen.
Für Claude Code brauchst du **keinen** API-Key (Abo-Login).

## Struktur

```
setup.sh            Orchestrator (frischer Mac)
Brewfile            alle Pakete
repos.txt           aktive Repos -> ~/dev
scripts/            clone-repos · macos-defaults · pre-wipe-backup
docs/               Cheat Sheet, Claude-Code-Workflow, Theming
home/               chezmoi-Quelle (.chezmoiroot zeigt hierher)
  dot_*             -> ~/.*
  dot_config/*      -> ~/.config/*
```
