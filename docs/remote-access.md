# Fern-Zugang & Multi-Device

Ein System, zwei Macs, ein gesperrter Büro-PC. Ziel: überall arbeiten, ohne
zwei Systeme zu lernen und ohne Policy-Ärger.

## Rollen

| Gerät | Rolle |
|-------|-------|
| **MacBook Air** (Apple Silicon) | Daily Driver. Geht mit ins Büro (**Gast-WLAN**). Alles lokal. |
| **iMac** (Intel) | Heim-Workstation. Gleiches Repo. Optionaler Tailscale-Knoten. |
| **Win11-Büro-PC** | Nur ZDF-Internes: Citrix + Office 365 im Browser. Wird nicht angetastet. |

## Im Büro arbeiten — der saubere Weg

**MacBook mitnehmen, ins Gast-WLAN.** Eigenes Gerät + Gast-Netz = kein Zugriff
auf die ZDF-Infrastruktur, kein Policy-Konflikt. Du hast deine native Umgebung
(nvim/tmux/CC) lokal. Der Firmen-PC bleibt für Citrix + office.com im Browser.

Optional, falls du das MacBook vergisst und die iMac-Dateien brauchst:
**Tailscale** ist auf beiden Macs installiert. Vom MacBook (auch im Gast-WLAN,
da eigenes Gerät) per `ssh imac` oder `mosh imac` an den iMac. Tailscale kommt
über 443/DERP auch durch restriktive Netze.

## Datenabgleich MacBook <-> iMac

- **Code:** git/GitHub. Beide klonen, `pull`/`push`. Erledigt.
- **Configs:** chezmoi + dieses Repo. Beide `chezmoi apply`. Erledigt.
- **Notizen (zk + jrnl, alles Text):** zwei Optionen —
  1. **git** (empfohlen, simpel): `~/zk` als privates Repo, `pull`/`push`. Versioniert.
  2. **Syncthing über Tailscale** (cloudlos, automatisch, Echtzeit): ein Daemon
     mehr, dafür kein manuelles Sync. `brew "syncthing"` im Brewfile einkommentieren.

**pass/GPG-Hinweis:** deine Secrets liegen in `pass`, verschlüsselt mit deinem
GPG-Key. Der Key muss auf **beide** Macs. Auf dem ersten exportieren, auf dem
zweiten importieren:
```sh
# Quelle:
gpg --export-secret-keys --armor DEINE_KEY_ID > key.asc
# Ziel (danach key.asc sicher löschen):
gpg --import key.asc && rm key.asc
git clone <dein-pass-repo> ~/.password-store   # falls pass-Store versioniert
```

## Break-Glass: Browser -> iMac (nur Notfall)

Wenn du *nur* den gesperrten PC hast und der Browser (HTTPS/443) geht: auf dem
iMac ein Web-Terminal (`ttyd`) oder Web-IDE (`code-server`), exponiert über
**Cloudflare Tunnel + Access** (authentifiziert, keine offenen Ports). Im Büro
eine URL öffnen → iMac-Umgebung im Browser.

**Zwei ehrliche Nachteile — deshalb nicht der Standardweg:**
1. **Policy.** Ein Tunnel vom ZDF-PC zu privater Technik kann gegen die
   Nutzungs-/Sicherheitsrichtlinie verstoßen. Deine Entscheidung.
2. **Chrome wird bei Neustart geleert.** Access-Login, Lesezeichen, Sitzung —
   jedes Mal neu. Täglich unpraktisch.

Deshalb: MacBook + Gast-WLAN schlägt diese Variante klar. Break-Glass nur, wenn
das MacBook partout nicht dabei ist. Einrichtung (falls gewünscht) liefere ich
separat — Tools stehen auskommentiert im Brewfile.
