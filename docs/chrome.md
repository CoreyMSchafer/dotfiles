# Chrome — einrichten & bedienen

Ziel: Chrome maximal bedienbar, reproduzierbar über beide Macs. Wichtig vorab:

> **Chrome installiert Extensions auf einem privaten (nicht-MDM) Mac nicht
> automatisch per Skript.** Das geht nur auf verwalteten Geräten. Der saubere
> Weg für „einmal einrichten, auf beiden Macs gleich" ist **Chrome-Sync**.

## 1. Cross-Machine: Chrome-Sync

In Chrome mit einem Google-Konto anmelden und Sync aktivieren → **Extensions,
Lesezeichen, Einstellungen und Autofill** landen automatisch auch auf dem iMac.
Das ist der reproduzierbare Mechanismus für dein „ein System, zwei Macs".
(Passt zu deinem Cloud-Setup mit Office 365/Teams. Wer keinen Google-Sync will:
Extensions je Gerät installieren, Lesezeichen unten per HTML importieren.)

## 2. Extensions (kuratiert, 2026-tauglich)

Öffnen lassen mit `./scripts/chrome-extensions.sh`, dann je Tab „Hinzufügen".

| Extension | Wofür | Warum für dich |
|-----------|-------|----------------|
| **Vimium** ⭐ | Vim-Navigation im Browser | `f` labelt jeden Link, `j/k` scrollt — Maus-frei, dein nvim-Reflex |
| **uBlock Origin Lite** | Werbung/Tracker | MV3-Version (die Vollversion läuft in Chrome nicht mehr) |
| **Dark Reader** | Dark Mode für alle Seiten | passt zu deinem Hell/Dunkel-Setup |
| **Privacy Badger** | Tracker-Blocker (EFF) | Open-Source, lernt mitlaufende Tracker |
| **ClearURLs** | entfernt Tracking-Parameter aus Links | leichtgewichtig, lokal |

Optional (Dev): **React Developer Tools**, **JSON Viewer**.
Optional (YouTube): **SponsorBlock** / **Unhook**.

**Sicherheit:** Anfang 2026 wurden 300 bösartige Extensions mit zusammen 37 Mio.
Downloads enttarnt. Deshalb: nur verifizierte/Open-Source-Extensions, Berechtigungen
prüfen, unter ~10–15 bleiben, Ungenutztes entfernen.

## 3. Lesezeichen

Fertige Struktur (Arbeit/ARTE · Dev · KI · Freizeit) liegt als
[`chrome-bookmarks.html`](chrome-bookmarks.html) bereit:
**Lesezeichen-Manager → ⋮ → Lesezeichen importieren → HTML-Datei**. Danach mit
Sync auch auf dem iMac. Lesezeichenleiste ein/aus: `⌘⇧B`.

## 4. Empfohlene Einstellungen (manuell, einmalig)

- **Beim Start:** „Dort fortfahren, wo du aufgehört hast" (Tabs überleben Neustart).
- **Passwörter:** „Speichern anbieten" **aus** — du nutzt `pass`. Fürs Web-Autofill
  optional Bitwarden, sonst manuell.
- **Suchmaschine:** nach Geschmack (Google/DuckDuckGo).
- **Office/Outlook als PWA:** in Chrome auf outlook.office.com / office.com →
  Adressleiste „Installieren"-Symbol → fühlt sich wie eine native App an.
  Genauso **Motion** über app.usemotion.com.

## 5. Vimium — die wichtigsten Tasten

| Taste | Aktion |
|-------|--------|
| `f` / `F` | Link anklicken / in neuem Tab |
| `j` / `k` | runter / hoch scrollen · `d` / `u` halbe Seite |
| `gg` / `G` | Seitenanfang / -ende |
| `o` / `O` | URL/Verlauf öffnen (aktueller / neuer Tab) |
| `T` | offene Tabs durchsuchen · `/` Seite durchsuchen |
| `H` / `L` | zurück / vor im Verlauf |
| `x` / `X` | Tab schließen / zuletzt geschlossenen wieder öffnen |
| `?` | alle Vimium-Tasten anzeigen |
