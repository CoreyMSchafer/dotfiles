# Cheat Sheet — täglicher Betrieb

Deine zentrale Referenz. Vertiefungen: [`claude-code.md`](claude-code.md) · [`theming.md`](theming.md)

---

## Nach dem Setup (einmalig)

Nach `./setup.sh` bleiben ein paar manuelle Schritte:

- **Apple-ID / iCloud** anmelden
- **Ghostty** einmal öffnen → wird zum Standard-Terminal (System-Einstellungen prüfen)
- **pass / GPG**: falls neu, `gpg --full-generate-key`, dann `pass init <GPG-ID>`. Keys ablegen: `pass insert anthropic/api-key`
- **Tailscale**: `tailscale up` (Login, verbindet mit iMac/Homelab)
- **Citrix**: Store-URL + Login der ARTE-Umgebung eintragen (Client bleibt privat, kein MDM)
- **Claude Code**: einmal `claude` starten → **Abo-Login** (kein API-Key nötig)
- **E-Mail (mutt-wizard)**: separat installieren, dann `mw -a sebastian.nuss@…`
- **p10k**: `p10k configure` (oder eigene `.p10k.zsh` ins Repo legen)
- **nvim**: einmal `nvim` öffnen → Plugins installieren sich selbst (`:Lazy` zum Prüfen)
- **Chrome**: `./scripts/chrome-extensions.sh` (Extensions), Lesezeichen aus
  `docs/chrome-bookmarks.html` importieren, dann mit Google-Konto anmelden →
  Sync spielt alles auf den iMac. Details: `docs/chrome.md`.
- **Beeper**: einmal öffnen, Konto anlegen, WhatsApp/Telegram per Gerät-Link koppeln.
- **Chrome-Sync** übernimmt danach Extensions/Lesezeichen automatisch auf dem iMac.
- **Secrets**: bei Bedarf `cp ~/.config/zsh/secrets.zsh.example ~/.config/zsh/secrets.zsh`

---

## chezmoi — Configs ändern

Nie direkt in `~/.zshrc` etc. editieren, sondern über die Repo-Quelle:

```sh
chezmoi edit ~/.zshrc     # bearbeiten (öffnet Quelle in nvim)
chezmoi apply             # ins $HOME übernehmen
chezmoi cd                # in die Quelle -> git add/commit/push, dann `exit`
chezmoi diff              # was würde sich ändern?
chezmoi re-add            # lokale Änderung zurück in die Quelle holen
```

**Merksatz:** `edit` → `apply` → committen.

---

## Shell — Aliase & moderne Tools

| Befehl | Tut | Ersetzt |
|--------|-----|---------|
| `ls` / `ll` / `la` | eza mit Icons/Git | ls |
| `lt` | Baum, 2 Ebenen | tree |
| `cat <datei>` | bat (Syntax, Zeilennr.) | cat |
| `z <teil>` | springt zu Verzeichnis (frecency) | cd |
| `y` | yazi öffnen, wechselt beim Verlassen dorthin | ranger |
| `lg` | lazygit (Git-TUI) | — |
| `v` / `vi` | nvim | vim |
| `rg <muster>` | ripgrep (schnelles grep) | grep |
| `fd <name>` | fd (schnelles find) | find |
| `dust` / `procs` / `btop` | du / ps / top (schöner) | — |
| `Strg-R` | atuin (durchsuchbare History) | reverse-search |
| `tldr <cmd>` | Beispiele statt man-Wüste | — |
| `greet` | Systeminfo + Wetter (auf Zuruf) | — |

Die Originale (`grep`, `find`, `cat` …) funktionieren weiter — wichtig auf Servern.

---

## tmux — Prefix ist `Strg-a`

| Taste | Aktion |
|-------|--------|
| `Strg-a │` | vertikal splitten |
| `Strg-a -` | horizontal splitten |
| `Strg-h/j/k/l` | **zwischen Panes UND nvim-Splits** navigieren (ohne Prefix!) |
| `Strg-a H/J/K/L` | Pane-Größe ändern |
| `Strg-a c` | neues Fenster · `Strg-a 1..9` Fenster wählen |
| `Strg-a d` | detach (Session läuft weiter) |
| `tmux a` | wieder attachen · `tmux ls` Sessions listen |
| `Strg-a [` | Copy-Mode (vi-Tasten, `Leertaste`/`Enter` kopieren) |
| `Strg-a r` | Config neu laden |
| `Strg-a I` | Plugins installieren (nach Config-Änderung) |

Sessions überleben Neustarts (resurrect/continuum) — einfach `tmux a`.

---

## nvim — Grundlagen (Leader = Leertaste)

**Modi:** `i` einfügen · `Esc` normal · `v` visuell · `:` Befehl.
**Bewegen:** `h j k l` · `w`/`b` Wort · `gg`/`G` Anfang/Ende · `Strg-d`/`Strg-u` halbe Seite.
**Editieren:** `dd` Zeile löschen · `yy` kopieren · `p` einfügen · `u` undo · `Strg-r` redo · `.` wiederholen.

> **which-key hilft beim Lernen:** Leertaste drücken und warten → alle verfügbaren
> Kürzel erscheinen. So lernst du die Maps nebenbei.

### Deine Leader-Maps

| Taste | Aktion |
|-------|--------|
| `␣w` / `␣q` | speichern / schließen |
| `␣-` / `␣│` | Split horizontal / vertikal |
| `⇧h` / `⇧l` | Buffer zurück / vor |
| **Finden (Telescope)** | |
| `␣ff` / `␣fg` | Dateien / Volltext (live grep) |
| `␣fb` / `␣fr` | Buffer / zuletzt geöffnet |
| `␣fk` | Keymaps durchsuchen (Spickzettel!) |
| **Git** | |
| `␣gp` / `␣gb` | Hunk ansehen / Blame |
| `]h` / `[h` | nächster / vorheriger Hunk |
| **Schreiben** | |
| `␣wz` / `␣ws` | Zen-Mode / Rechtschreibung |
| **UI** | |
| `␣uc` | Colorscheme wechseln (Preview) |
| `␣uz` | Fenster zoomen |
| **LSP (Code-Review)** | |
| `gd` / `K` | Definition / Hover |
| `gra` / `grn` / `grr` | Code-Action / Rename / Referenzen |

### Zettelkasten (zk)

| Taste | Aktion |
|-------|--------|
| `␣zd` / `␣za` / `␣zp` | neue Notiz in diss / ap / p |
| `␣zo` / `␣zf` / `␣zt` | öffnen / Volltext / Tags |
| `␣zi` (visuell) | Auswahl als Link einfügen |
| `␣zb` / `␣zl` | Backlinks / Links |

Im Terminal: `nd "Titel"` (diss), `na` (ap), `np` (p).

---

## Claude Code — der Vibe-Coding-Loop

Kurzfassung (Details in [`claude-code.md`](claude-code.md)):

1. In nvim arbeiten. CC-Pane öffnen: `␣cc` (erscheint als tmux-Split).
2. Mit `Strg-h/j/k/l` zwischen nvim und CC-Pane wechseln.
3. Code-Stelle an CC schicken: markieren (`v`), dann `␣cs`.
4. CC schlägt Änderungen vor → **Inline-Diff in nvim**. Prüfen, ggf. anpassen.
5. Annehmen mit `:w` oder `␣ca`. Verwerfen: `␣cx`.

CC macht die KI-Arbeit — nvim braucht **keine** KI-Plugins.

CC **Augen im Browser** geben (Console/Netzwerk/Performance live prüfen):
Chrome DevTools MCP — Einrichtung + Nutzung in `docs/claude-code.md`.
Bei Fertigstellung meldet sich CC per Ton/Notification (terminal-notifier).

---

## git & lazygit

- `lg` — lazygit: stagen (`Leertaste`), committen (`c`), pushen (`P`), Branches (`b`), Log (`Enter`).
- `git s` Kurzstatus · `git lg` Graph · `git wt` worktree (für parallele CC-Agenten).
- Diffs erscheinen via **delta** (Zeilennummern, Syntax) — auch in `git diff`.

**Parallele Agenten:** pro Feature ein worktree + tmux-Fenster:
```sh
git worktree add ../feature-x -b feature-x
tmux new-window -c ../feature-x 'claude'
```

---

## Lesen & Journal

- **newsboat**: `newsboat` starten · `r` Feed neu laden, `R` alle · `t` nach Tag filtern
  (`ki-labore`, `ki-forschung`, `ki-analyse`, `wissenschaft`, `wissenschaft-de`) ·
  `,o` im Browser, `,w` in w3m, `,v` als Video (mpv).
- **jrnl**: `jrnl heute: Text` schreiben · `jrnl -n 5` letzte Einträge ·
  `jrnl diss heute: …` ins Forschungstagebuch.

---

## Freizeit im Terminal

### Anime — ani-cli
```sh
ani-cli                 # suchen & schauen (spielt via mpv/iina)
ani-cli -c              # zuletzt Geschautes fortsetzen
ani-cli -d "Titel"      # herunterladen
ani-cli -U              # ani-cli aktualisieren (kein Brew-Update!)
```
Auf macOS ist iina Default; mpv (hast du) geht ebenso — Player-Wahl siehe `ani-cli -h`.

### MUDs — Blightmud (modern) / TinTin++ (klassisch)
```sh
blightmud               # Rust-Client, Lua-Scripting, Split-View
#   im Client:  /connect <host> <port>   ·   /help
tt++                    # TinTin++  ·  im Client:  #session name host port
```
Zum Einsteigen (Fantasy/Adventure):
- **Discworld MUD** — `discworld.starturtle.net 4242` (Pratchett-Welt, tolle Texte)
- **Aardwolf** — `aardwolf.com 4000` (riesig, anfängerfreundlich)
- **BatMUD** — `batmud.bat.org 23` (Klassiker, gewaltig)

Falls die Blightmud-Formel zickt (Apple Silicon): `brew tap Blightmud/blightmud` ist gesetzt; sonst `cargo install --git https://github.com/blightmud/blightmud blightmud`.

### Interactive Fiction — frotz
```sh
frotz spiel.z5          # curses-Oberfläche
dfrotz spiel.z5         # „dumb terminal" (gut für tmux/Logs)
#   im Spiel:  look · inventory · save · restore · quit
```
Spiele holen (`.z5`/`.zblorb`): **[ifdb.org](https://ifdb.org)** (Datenbank + Download) und **[ifarchive.org](https://ifarchive.org)**. Dort findest du **Zork I–III** und hunderte frei verfügbare Klassiker. Empfehlenswert: *Anchorhead* (Horror), *Lost Pig* (witzig, ideal zum Einstieg), *Counterfeit Monkey* (Wortspiel-Epos), *Spider and Web*, *9:05*.

---

## Hell/Dunkel umschalten

Ein Hotkey kippt **alles** (Ghostty, nvim, tmux) — siehe [`theming.md`](theming.md).
Kurz: macOS-Erscheinung togglen, der Rest folgt automatisch (Rosé Pine Main ⇄ Dawn).

## Täglicher Start & Skript-Trockenlauf

- `morgen` — Arbeitstag-Onboarding: Wetter, Motion-Tasks (heute), Newsboat-Ungelesen,
  Fokus-Anker. Motion-Key einmalig: `pass insert motion/api-key`.
- `./setup.sh --check` — Trockenlauf: zeigt gefahrlos, was ein echter Lauf täte.
- `./setup.sh --plain` — ohne Animationen (Pipes/CI/Debug); Pakete einzeln + verbose.
- Testplan fürs Setup-Skript: `docs/testing.md`.
