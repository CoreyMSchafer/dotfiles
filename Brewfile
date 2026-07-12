# ============================================================================
#  Brewfile — Sebastians optimaler macOS-Stack.  Anwenden:  brew bundle
#  Persönliche Extra-Apps unten unter "Optional" ergänzen.
# ============================================================================

# --- Taps ---

# --- Terminal, Shell, Editor ---
brew "tmux"
brew "neovim"
brew "tree-sitter"                # tree-sitter CLI (nvim)
brew "mise"                       # EIN Runtime-Manager (ersetzt nvm/rbenv/pyenv/conda)

# --- Moderner CLI-Stack (2026) ---
brew "eza"                        # ls
brew "bat"                        # cat
brew "ripgrep"                    # grep
brew "fd"                         # find
brew "zoxide"                     # cd (frecency)
brew "fzf"                        # fuzzy finder
brew "atuin"                      # shell history (SQLite)
brew "git-delta"                  # git diff
brew "dust"                       # du
brew "procs"                      # ps
brew "sd"                         # sed (einfach)
brew "hyperfine"                  # benchmarking
brew "btop"                       # top
brew "tldr"                       # man (Beispiele)
brew "lazygit"                    # git TUI
brew "yazi"                       # Datei-Manager (ersetzt ranger, Bildvorschau)
brew "glow"                       # Markdown im Terminal
brew "jq"
brew "yq"
brew "gh"                         # GitHub CLI

# --- Notizen / Recherche / Lesen ---
brew "zk"                         # Zettelkasten
brew "jrnl"                       # Journal
brew "newsboat"                   # RSS (Wissenschaft + KI)
brew "w3m"                        # Terminal-Browser (für newsboat)

# --- E-Mail-Stack (mutt-wizard) ---
brew "neomutt"
brew "isync"                      # mbsync
brew "msmtp"
brew "pass"                       # Passwörter (du nutzt es schon) + Secrets
brew "gnupg"
# mutt-wizard separat installieren:  curl -LO github.com/LukeSmithxyz/mutt-wizard ... (siehe docs)

# --- Medien / Tools ---
brew "mpv"
brew "yt-dlp"
brew "terminal-notifier"          # CC-Benachrichtigung bei Fertigstellung

# --- Freizeit / Terminal-Spaß ---
brew "tintin"                     # MUD-Client (klassisch, Binary: tt++)
# blightmud (moderner Rust-MUD) NICHT hier: liegt in einem fremden Tap, den
# Homebrew nicht-interaktiv blockt. Bei Bedarf manuell:
#   brew tap blightmud/blightmud && brew install blightmud
#   (fragt einmal nach Vertrauen für den Tap; im Skript bewusst vermieden)
brew "frotz"                      # Interactive Fiction (Z-machine: Zork & Co.)
brew "ffmpeg"                     # ani-cli-Abhängigkeit (nützt auch yt-dlp)
brew "aria2"                      # ani-cli-Downloads
# ani-cli selbst hat KEINE Brew-Formel -> Installation via
# run_once_after_30-ani-cli.sh (git clone). Update später: ani-cli -U

# --- Dotfile-Manager ---
brew "chezmoi"

# --- Fonts ---
cask "font-fira-code-nerd-font"

# --- Apps ---
cask "ghostty"                    # Terminal
cask "tailscale"                  # Mesh-Netz zu iMac/Homelab
cask "citrix-workspace"           # ARTE-Umgebung
cask "google-chrome"              # Browser (Extensions) + Office 365 im Web/PWA
cask "microsoft-teams"            # Haupt-Kommunikation (Calls/Chat) — nativ = beste Call-Qualität
cask "rectangle"                  # Fenster per Tastenkürzel (keyboard-first)
# Office 365 + Outlook Web: keine Installation -> office.com / outlook.office.com
#   im Chrome als PWA installierbar (empfohlen für die ARTE-Mail)
# cask "microsoft-outlook"        # Outlook NATIV — nur wenn dir Web bei viel Mail zu wenig ist
# cask "zoom"                     # nur falls externe Partner Zoom statt Teams nutzen

# --- Kommunikation & Persönliches (von dir gewünscht) ---
cask "beeper"                     # elegante Sammellösung: WhatsApp+Telegram+Signal+… in EINER App
                                  #   (on-device-verschlüsselt; Teams bleibt separat nativ oben)
# Alternative statt Beeper — offizielle Einzel-Apps:
# cask "whatsapp"
# cask "telegram"
# Motion: als Chrome-PWA (app.usemotion.com -> "Installieren") — passt zu "Office im Browser".
# cask "motion"                   # native App optional; Cask vor Nutzung verifizieren

# --- Optional: Abgleich & Fern-Zugang (bei Bedarf einkommentieren) ---
# brew "syncthing"                # cloudloser Echtzeit-Abgleich (zk/Notizen) via Tailscale
# brew "mosh"                     # robustes SSH (MacBook -> iMac über wackliges WLAN)
# brew "cloudflared"             # nur für die Break-Glass-Browser-Variante (siehe docs)
# brew "ttyd"                    # Web-Terminal (nur Break-Glass)

# --- Optional (auskommentiert — bei Bedarf aktivieren) ---
# cask "visual-studio-code"       # GUI-Editor (du arbeitest in nvim)
# cask "orbstack"                 # schneller Docker-Ersatz
# cask "1password"                # falls du doch 1Password willst
