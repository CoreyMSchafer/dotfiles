# setup.sh testen — Senior-Testplan

Ziel: das Skript vor dem echten MacBook-Wipe mit ruhigem Gewissen laufen lassen.
Kernproblem vorweg, ehrlich: **ein macOS-Bootstrap mit Casks, `defaults`, Fonts,
sudo und GUI lässt sich NICHT in einem Linux-Container oder in dieser
Claude-Session testen** (kein macOS, hier zusätzlich kein Netz). Reale Projekte
schließen in ihrer CI genau diese Teile aus und testen sie in einer sauberen
macOS-VM. Deshalb ein Schichten-Ansatz.

## Schicht 1 — Statisch (schnell, überall)

- `bash -n setup.sh scripts/*.sh` — Syntax (bei jeder Änderung; ist grün).
- `brew install shellcheck && shellcheck setup.sh scripts/*.sh` — Logikfehler,
  Quoting, unsichere Muster.
- `./setup.sh --check` — **Trockenlauf**: Preflight + `brew bundle check`
  (zeigt fehlende/auflösbare Pakete) + Liste der zu klonenden Repos. Ändert nichts.
  Läuft gefahrlos auf deinem jetzigen Mac und deckt Tippfehler/verwaiste
  Cask-Namen im Brewfile auf.

## Schicht 2 — Test-User auf diesem Mac (pragmatisch, non-destruktiv)

Testet zuverlässig die **User-Ebene**: chezmoi, zsh-Start, nvim-Bootstrap,
run_once (mise/tpm/ani-cli), per-User-Defaults, die Parallel-Logik, das Logging.

```bash
# Test-User anlegen (Admin, damit Cask-Installer sudo bekommen)
sudo sysadminctl -addUser testflow -fullName "Test Flow" -password - -admin
# Aus-/Einloggen als testflow (oder schnelle Benutzerumschaltung), dann:
git clone https://github.com/ur-grue/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./setup.sh
# ... prüfen (Checkliste unten) ...
# Aufräumen (zurück im eigenen Account):
sudo sysadminctl -deleteUser testflow
```

Ehrliche Grenze: Homebrew und die meisten Casks sind **systemweit** (`/opt/homebrew`,
`/Applications`) — ein zweiter User findet sie schon vor. `brew bundle` no-op-t
dann weitgehend, d. h. der *Frisch-Install-* und *Parallel-Timing*-Pfad wird hier
**nicht** voll durchlaufen. Für alles User-seitige ist es trotzdem der schnellste
echte Test.

## Schicht 3 — Saubere VM (Goldstandard, nur Apple Silicon)

Testet den kompletten Pfad von null inkl. Homebrew + Casks + Timing, ohne deine
echte Maschine anzufassen. Werkzeug: **Tart** (Apple Virtualization.framework).

```bash
brew install cirruslabs/cli/tart
tart clone ghcr.io/cirruslabs/macos-sequoia-base:latest test-vm   # ~25–50 GB
tart run test-vm &                                                 # bootet ~20–40s
ssh admin@$(tart ip test-vm)      # Passwort i. d. R. "admin"
#   → im Gast: git clone … && cd dotfiles && ./setup.sh
tart stop test-vm && tart delete test-vm   # wegwerfen; oder Snapshot für Wiederholung
```

Das ist die faithful-Variante. Etwas Aufwand (Image-Download), dafür beliebig oft
sauber wiederholbar.

## Schicht 4 — Das echte MacBook

Nach 1–3 grün ist der reale Lauf risikoarm. `setup.sh` ist idempotent; bricht etwas
ab, sagt das Log (`~/.dotfiles-setup-<zeit>.log`) genau wo, und ein erneuter Lauf
macht dort weiter.

## Die „in Claude Code testen lassen"-Idee — richtig eingeordnet

- **Diese Session** (Linux, Netz aus) kann NUR statisch prüfen und das Skript
  härten. Sie kann den macOS-Lauf nicht ausführen.
- **CC auf deinem Mac** kann Schicht 2/3 dagegen sehr gut orchestrieren: Test-User
  oder Tart-VM starten, `./setup.sh` laufen lassen, das Log live mitlesen, Fehler
  analysieren und Fixes vorschlagen. Genau dafür ist das Voll-Logging da. Das ist
  die produktive Form deiner Idee.

## Watch-Liste (gezielt prüfen — aus dem Repo-Audit)

- **nvim LSP** (`lua/plugins/lsp.lua`): nach `nvim` einmal `:checkhealth` und eine
  .lua/.py-Datei öffnen — hängt der Server an (`gd`, `K`)? Der wahrscheinlichste
  Nachbesserungspunkt (LSP-API im Umbruch).
- **Cask-Namen**: `--check` bzw. der echte Install zeigen verwaiste/umbenannte Casks.
- **E-Mail**: `mw` (mutt-wizard) wird bewusst NICHT automatisch installiert — der
  E-Mail-Stack (neomutt/isync/msmtp) schon. `mw` ist ein manueller Extra-Schritt.
- **RSS-Feeds**: einzelne 404 sind normal (in newsboat entfernen).
- **chezmoi-Quelle**: nach dem Lauf `chezmoi diff` ohne `--source` testen — dank
  `sourceDir` in der Config sollte es das Repo finden.
- **Private Repos**: ohne `gh auth login` schlagen sie im Klon-Job kontrolliert
  fehl (kein Hängen); nach Login `./scripts/clone-repos.sh` erneut.
