# setup.sh — Robustheit & Performance

## Leitprinzip: ein Fehler stoppt nie den ganzen Lauf

Pakete werden **einzeln** installiert (`brew install <name>`), nicht als
Monolith (`brew bundle`). Schlägt eines fehl — kaputter Cask, Netz-Hänger,
umbenanntes Paket — wird es **geloggt und übersprungen**, der Rest läuft weiter.
Am Ende erscheint eine Liste der übersprungenen Pakete; nachinstallieren später
mit `brew install <name>`. (Der frühere `brew bundle`-Ansatz riss bei EINEM
Problem alles mit — z. B. der untrusted Blightmud-Tap.)

Zusätzlich ist jeder Schritt idempotent: bereits Installiertes wird erkannt und
übersprungen, ein zweiter Lauf ist schnell.

## Was parallel läuft (Ablaufplan)

```
CLT ─▶ Homebrew ─▶ ┌─ PACKAGES  (einzeln, isoliert, Fortschrittsbalken)
                   ├─ SHELL     oh-my-zsh + p10k + Plugins   ┐
                   ├─ CLONES    12 Repos (xargs -P 6)         ├ gleichzeitig
                   └─ SYSTEM    macOS-Defaults                ┘
                        ─▶ chezmoi (mise/tpm/ani-cli) ─▶ Claude Code
```

Die drei Nicht-brew-Subsysteme laufen im Hintergrund **neben** der
Paketinstallation und verstecken sich unter deren Laufzeit. Im TTY zeigt ein
Live-Dashboard alle vier gleichzeitig; sonst (`--plain`) linear und verbose.

## Weitere Hebel

- `HOMEBREW_NO_AUTO_UPDATE` / `NO_INSTALL_CLEANUP` — spart teuren Vor-/Nachlauf.
- Repo-Klone untereinander parallel (`xargs -P 6`).
- sudo einmal gecacht + still am Leben gehalten (Cask-Installer stocken nicht).
- caffeinate — kein Ruhezustand während der Installation.
- Voll-Logging in `~/.dotfiles-setup-<zeit>.log` (inkl. aller Job-Logs).

## Bewusster Trade-off (ehrlich)

Die Einzelinstallation opfert Homebrews interne Parallelität (`brew bundle
--parallel`) zugunsten echter **Fehler-Isolation** — das war die Priorität.
Die Casks (die großen Downloads) sind ohnehin netz-gebunden und bleiben der
Boden der Gesamtzeit. Wer später Tempo gegen etwas Komplexität tauschen will,
kann kontrollierte Parallelität (begrenztes `xargs -P` über `brew install`)
nachrüsten — dann aber mit Blick auf Homebrews Lock.

## Bewusst NICHT gemacht

- Keine mehreren gleichzeitigen `brew`-Prozesse (Lock-Kollision, Concurrency-Bugs).
- chezmoi-run_once bleibt sequenziell (Korrektheit vor Mikro-Gewinnen).
- Fehler werden nie verschluckt: eigenes Log je Subsystem + Report am Ende.
