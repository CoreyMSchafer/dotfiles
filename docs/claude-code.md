# Claude Code — Vibe Coding in nvim + tmux

Ziel: nvim ist deine kreative Fläche, CC der Agent im Neben-Pane. Volle
IDE-Integration (Inline-Diffs), ohne die Maus, alles im Terminal.

## Was installiert ist

- **`coder/claudecode.nvim`** — startet einen WebSocket-Server mit *demselben
  Protokoll wie die offizielle VS-Code-Extension*. CC erkennt nvim automatisch,
  bekommt Editor-Zugriff und zeigt Änderungen als **native Diffs in nvim**.
- **`mr55p-dev/claude-tmux.nvim`** — öffnet CC in einem echten **tmux-Pane**
  statt im nvim-Fenster.
- **`christoomey/vim-tmux-navigator`** — `Strg-h/j/k/l` bewegt dich nahtlos
  zwischen nvim-Splits und tmux-Panes (also auch rein/raus zum CC-Pane).

## Verbindung herstellen

`␣cc` öffnet den CC-Pane und verbindet ihn automatisch mit nvim. Falls du CC
lieber selbst startest: im tmux-Pane `claude` starten und in CC `/ide` tippen —
es findet die laufende nvim-Instanz über die Lock-Datei (`~/.claude/ide/`).

## Der Loop

```
┌─────────────────┬──────────────────┐
│                 │                  │
│   nvim          │   Claude Code    │
│   (Code + Diff) │   (Agent)        │
│                 │                  │
└─────────────────┴──────────────────┘
        ↑  Strg-h/j/k/l wechselt  ↓
```

1. **Schreiben/lesen** in nvim wie gewohnt (Telescope, LSP, Treesitter).
2. **Kontext geben:** Stelle markieren (`v`/`V`), `␣cs` schickt die Auswahl an CC.
   Oder CC einfach im Pane bitten — es kann deine offenen Dateien lesen.
3. **CC arbeitet**, schlägt Änderungen vor → **Inline-Diff in nvim**.
4. **Review:** Diff lesen, bei Bedarf direkt editieren (es ist dein Buffer).
5. **Annehmen** mit `:w` oder `␣ca`. **Verwerfen:** `␣cx` (alle Diffs schließen).

| Taste | Aktion |
|-------|--------|
| `␣cc` | CC-Pane öffnen/schließen |
| `␣cs` (visuell) | Auswahl an CC senden |
| `␣ca` / `:w` | vorgeschlagenen Diff annehmen |
| `␣cx` | alle offenen Diffs schließen |
| `Strg-h/j/k/l` | zwischen nvim und CC-Pane wechseln |

## Gute Praxis

- **Plan-Mode zuerst:** in CC mit `⇧Tab` in den Plan-Modus — erst denken lassen,
  Plan prüfen, dann ausführen. Spart Fehl-Runden.
- **Klein halten:** ein Thema pro Anfrage; große Aufgaben in Schritte zerlegen.
- **Reviewen statt blind mergen:** die Inline-Diffs sind genau dafür da.

## Parallele Agenten (git worktrees + tmux)

Mehrere Features gleichzeitig, jedes isoliert:

```sh
git worktree add ../projekt-feature-x -b feature-x
tmux new-window -c ../projekt-feature-x 'claude'
```

Jedes tmux-Fenster = ein Agent in eigenem Worktree. Mit `Strg-a 1..9` wechseln,
Fortschritt in jedem Pane sichtbar. Ghostty rendert das per GPU flüssig.

## Benachrichtigung bei Fertigstellung

Ein CC-Stop-Hook meldet sich, wenn ein Lauf fertig ist — du musst nicht
danebensitzen. In `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [{ "hooks": [{ "type": "command",
      "command": "terminal-notifier -title 'Claude Code' -message 'fertig' -sound Glass" }]}]
  }
}
```

(Alternativ `say fertig` statt terminal-notifier.)

## Von überall arbeiten (Tailscale)

CC-Session auf dem iMac laufen lassen, per **Tailscale** vom MacBook drauf,
`tmux a` — die Session lebt weiter, egal ob die Verbindung kurz abreißt.
Terminal-natives „Vibe Coding anywhere", ohne GUI-Remote.

## nvim beherrschen — der schnelle Weg

Du brauchst nur einen kleinen Kern: die Bewegungen (`h j k l`, `w`, `gg`/`G`),
Editieren (`d`, `y`, `p`, `.`), und den CC-Loop oben. **which-key** (Leertaste
drücken) zeigt dir die Maps, während du sie lernst. Einmal `vimtutor` im Terminal
durchziehen (20 Min.) legt das Fundament — den Rest lernst du im echten Tun.

---

## Claude Code Augen im Browser geben — Chrome DevTools MCP

CC schreibt Web-Code, sieht aber normalerweise nicht, was der im Browser tut.
**Chrome DevTools MCP** schließt genau diese Lücke: CC steuert eine laufende
Chrome-Instanz und liest **Konsolen-Fehler (mit source-gemappten Stacktraces),
Netzwerk-Requests, Screenshots, Performance-Traces und a11y-Audits**.

### Installation (in Claude Code)

Empfohlen als voll­ständiges Plugin (bringt MCP-Server + Skills für a11y,
Performance, Troubleshooting):
```
/plugin marketplace add ChromeDevTools/chrome-devtools-mcp
/plugin install chrome-devtools-mcp@chrome-devtools-plugins
```
Minimal (nur der Server):
```
claude mcp add chrome-devtools npx chrome-devtools-mcp@latest
```
Voraussetzungen: Node 22+ und Chrome 144+ (via mise/Brew bist du da).

### Wie es sich verbindet — sicher

- **Standard (empfohlen):** ohne Extra-Flag startet der MCP-Server eine EIGENE,
  frische Chrome-Instanz, sobald CC ein Browser-Tool nutzt. Null Setup, keine
  Sicherheits­exposition. Ideal, um deine localhost-Apps zu testen/debuggen.
- **Für Logins nötig?** Dann eine ISOLIERTE Debug-Instanz mit
  `./scripts/chrome-debug.sh` (eigenes Profil, Port 9222).
- **Nicht** Remote-Debugging auf deinem echten Chrome mit ARTE-/Privat-Logins
  aktivieren — Port 9222 wäre für jeden lokalen Prozess offen.

### So nutzt du es

CC im tmux-Pane, dein Dev-Server läuft, dann z. B.:
- „Prüfe die Console-Fehler auf localhost:3000 und schlage Fixes vor."
- „Zeichne einen Performance-Trace auf und nenn mir die LCP-Bremsen."
- „Mach einen a11y-Scan der Checkout-Seite (Kontrast, ARIA-Labels)."

Der Loop wird damit rund: nvim (schreiben) → CC (bauen) → DevTools MCP
(im Browser prüfen) → Fix als Inline-Diff → `:w`.
