# Theming — Hell/Dunkel automatisch

Ein Farbschema für alles: **Rosé Pine**. Hell = Dawn, Dunkel = Main. Der ganze
Stack folgt der macOS-Erscheinung **live** — du stellst nichts einzeln um.

## Wie es zusammenspielt

| Ebene | Mechanik |
|-------|----------|
| **Ghostty** | `theme = light:rose-pine-dawn,dark:rose-pine` — folgt macOS nativ |
| **nvim** | `auto-dark-mode.nvim` kippt den Hintergrund; rose-pine `variant="auto"` → Main/Dawn |
| **tmux** | Statuszeile `bg=default` → erbt die Terminalfarbe, folgt also mit |
| **bat/delta** | `--theme=ansi` → nutzt die Terminal-Palette, folgt mit |

Weil alles der Terminal- bzw. System-Erscheinung folgt, reicht **eine** Umschaltung.

## Ein Hotkey für alles

Statt in jedem Tool zu fummeln: einen globalen Kurzbefehl anlegen, der die
**macOS-Erscheinung** togglet — Ghostty, nvim und tmux ziehen automatisch nach.

1. **Automator** öffnen → *Neu* → **Schnellaktion (Quick Action)**.
2. Aktion **„Systemerscheinung ändern"** hineinziehen, auf **„Hell/Dunkel umschalten"** stellen.
3. Speichern, z. B. als *Erscheinung umschalten*.
4. **Systemeinstellungen → Tastatur → Tastaturkurzbefehle → Dienste** →
   der Aktion einen Shortcut geben (z. B. `⌃⌥⌘L`).

Ab jetzt: Hotkey drücken → alles kippt gemeinsam Hell ⇄ Dunkel.

## Theme manuell wechseln (zum Ausprobieren)

- **nvim:** `␣uc` → Telescope-Picker mit Live-Preview (Kanagawa, Catppuccin, Vague liegen bereit).
- **Ghostty:** `ghostty +list-themes` zeigt alle; Namen in die Config eintragen.

## Rosé-Pine-Variante fürs Terminal (optional)

`bat`/`delta` nutzen `ansi` (folgt dem Terminal, immer stimmig). Willst du dort
echtes Rosé Pine statt ANSI, lässt sich das Theme nachrüsten (`bat cache --build`) —
für den Alltag ist `ansi` aber der einfachere, konsistente Weg.
