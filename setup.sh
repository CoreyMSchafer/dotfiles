#!/usr/bin/env bash
# ============================================================================
#  AUTOPUNK // BOOTSTRAP — frischer macOS-Dev-Setup.
#      ./setup.sh            # voller Lauf (Cyberpunk-Dashboard, wenn TTY)
#      ./setup.sh --check    # Trockenlauf: zeigt, was fehlt (0 Änderungen)
#      ./setup.sh --plain    # ohne Animationen (Pipes/CI/Debug)
#
#  ROBUSTHEIT: Pakete werden EINZELN installiert. Schlägt eines fehl, wird es
#  geloggt und ÜBERSPRUNGEN — der Rest läuft weiter. Am Ende: Liste der
#  übersprungenen Pakete. Voll-Log: ~/.dotfiles-setup-<zeit>.log
# ============================================================================
set -euo pipefail

# ---- Argumente ----
MODE=run; PLAIN=0
for a in "${@:-}"; do case "$a" in
  --check|--dry-run) MODE=check ;;
  --plain)           PLAIN=1 ;;
  --help|-h) sed -n '2,12p' "$0"; exit 0 ;;
esac; done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$HOME/.dotfiles-setup-$(date +%Y%m%d-%H%M%S).log"
LOGD="$(mktemp -d)"
START=$(date +%s)
: > "$LOG"

# ---- Farben / TTY / Dashboard-Erkennung ----
COLOR=0; TUI=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then COLOR=1; fi
if [ "$COLOR" = 1 ] && [ "$PLAIN" = 0 ]; then TUI=1; fi
if [ "$COLOR" = 1 ]; then
  R=$'\033[0m'; PINK=$'\033[38;5;198m'; CYAN=$'\033[38;5;51m'; GREEN=$'\033[38;5;46m'
  YELLOW=$'\033[38;5;226m'; PURPLE=$'\033[38;5;135m'; DIM=$'\033[38;5;240m'; RED=$'\033[38;5;196m'
else R=''; PINK=''; CYAN=''; GREEN=''; YELLOW=''; PURPLE=''; DIM=''; RED=''; fi
FR=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏); NF=${#FR[@]}; _fri=0; _first=1

# ---- Log + Ausgabe ----
logline() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*" >> "$LOG"; }
step() { printf '\n%s\n' "${PINK}▓▒░${R} ${CYAN}$*${R}"; logline ">> $*"; }
ok()   { printf '%s\n' "  ${GREEN}✔${R} $*"; logline "OK $*"; }
warn() { printf '%s\n' "  ${YELLOW}▲ $*${R}"; logline "WARN $*"; }
die()  { printf '%s\n' "  ${RED}✖ $*${R}"; logline "DIE $*"; exit 1; }

# ---- Traps ----
cleanup(){ printf '\033[?25h'; kill "${CAFF_PID:-}" "${SUDO_PID:-}" 2>/dev/null || true; }
trap cleanup EXIT INT TERM
trap 'ec=$?; if [ "$ec" -ne 0 ]; then printf "\n%s\n" "${RED:-}✖ Fehler (Exit $ec) Zeile ${LINENO}: ${BASH_COMMAND}${R:-}"; logline "ERR ${LINENO}: ${BASH_COMMAND}"; printf "%s\n" "  ${DIM:-}Log: ${LOG}${R:-}"; fi' ERR

# ---- Banner ----
banner() {
  printf '\n'
  printf '%s\n' "${PINK}   ▟████████████████████████████████████████████▙${R}"
  printf '%s\n' "${PINK}   █${CYAN}     A U T O P U N K   //   B O O T S T R A P     ${PINK}█${R}"
  printf '%s\n' "${PINK}   ▜████████████████████████████████████████████▛${R}"
  printf '%s\n' "${DIM}   macOS dev-env · $(sw_vers -productVersion 2>/dev/null || echo '?') · $(date '+%Y-%m-%d %H:%M')${R}"
}
banner

# ---- Preflight ----
step "Preflight"
[ "$(uname -s)" = "Darwin" ] || die "Läuft nur unter macOS."
ARCH="$(uname -m)"
printf '%s\n' "  ${DIM}macOS $(sw_vers -productVersion 2>/dev/null) · $ARCH · $(id -un) · Log $LOG${R}"
FREE_GB="$(df -g / 2>/dev/null | awk 'NR==2{print $4}')"
{ [ "${FREE_GB:-0}" -ge 15 ]; } 2>/dev/null || warn "Nur ${FREE_GB:-?}G frei — Casks brauchen Platz (>=15G empfohlen)."
curl -fsI --max-time 8 https://formulae.brew.sh >/dev/null 2>&1 || die "Kein Netz (formulae.brew.sh nicht erreichbar)."
for f in Brewfile repos.txt scripts/clone-repos.sh scripts/macos-defaults.sh; do
  [ -e "$REPO_DIR/$f" ] || die "Datei fehlt im Repo: $f"
done
ok "Preflight ok"

# ---- Brewfile parsen (Formeln + Casks) ----
BREWS=(); CASKS=()
while IFS= read -r line; do
  t="${line#"${line%%[![:space:]]*}"}"
  case "$t" in
    'brew "'*) n="${t#brew \"}"; n="${n%%\"*}"; BREWS+=("$n") ;;
    'cask "'*) n="${t#cask \"}"; n="${n%%\"*}"; CASKS+=("$n") ;;
  esac
done < "$REPO_DIR/Brewfile"
TOTAL=$(( ${#BREWS[@]} + ${#CASKS[@]} ))

# ---- Trockenlauf ----
if [ "$MODE" = "check" ]; then
  step "TROCKENLAUF — nichts wird verändert ($TOTAL Pakete im Brewfile)"
  if command -v brew >/dev/null 2>&1; then
    miss=0
    for f in "${BREWS[@]}"; do
      if brew list --formula --versions "$f" >/dev/null 2>&1; then printf '%s\n' "  ${GREEN}✔${R} ${DIM}$f${R}"
      else printf '%s\n' "  ${YELLOW}○${R} $f ${DIM}(würde installiert)${R}"; miss=$((miss+1)); fi
    done
    for f in "${CASKS[@]}"; do
      if brew list --cask --versions "$f" >/dev/null 2>&1; then printf '%s\n' "  ${GREEN}✔${R} ${DIM}$f${R}"
      else printf '%s\n' "  ${YELLOW}○${R} $f ${DIM}(cask, würde installiert)${R}"; miss=$((miss+1)); fi
    done
    printf '%s\n' "  ${CYAN}$miss fehlen, $((TOTAL-miss)) vorhanden${R}"
  else warn "Homebrew noch nicht da — Paket-Check erst nach Erstlauf."; fi
  step "Repos, die geklont würden"
  grep -vE '^[[:space:]]*(#|$)' "$REPO_DIR/repos.txt" | while read -r u; do
    nm="$(basename "$u" .git)"; { [ -d "$HOME/dev/$nm" ] && printf '%s\n' "  ${GREEN}✔${R} ${DIM}$nm${R}"; } || printf '%s\n' "  ${YELLOW}○${R} $nm"
  done
  step "Trockenlauf fertig — Log: $LOG"; exit 0
fi

# ---- Umgebung ----
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_ENV_HINTS=1
export GIT_TERMINAL_PROMPT=0
caffeinate -dimsu & CAFF_PID=$!

# ---- 1. Xcode CLT (Gate) ----
if ! xcode-select -p >/dev/null 2>&1; then
  step "Xcode Command Line Tools installieren…"
  xcode-select --install 2>/dev/null || true
  warn "CLT-Installation abschließen, dann ./setup.sh erneut ausführen."; exit 0
fi

# ---- 2. sudo cachen + still am Leben halten ----
step "Adminrechte einmalig (nur für App-/Cask-Installer)…"
sudo -v || warn "Ohne sudo scheitern evtl. einzelne Casks — Lauf geht trotzdem weiter."
( while kill -0 "$$" 2>/dev/null; do sudo -n -v 2>/dev/null || true; sleep 50; done ) & SUDO_PID=$!

# ---- 3. Homebrew (Gate) ----
if ! command -v brew >/dev/null 2>&1; then
  step "Homebrew installieren…"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if   [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew   ]; then eval "$(/usr/local/bin/brew shellenv)"
else die "brew nach Installation nicht gefunden."; fi
if [ "$ARCH" = "arm64" ] && ! /usr/bin/pgrep -q oahd; then
  step "Rosetta 2…"; softwareupdate --install-rosetta --agree-to-license >/dev/null 2>&1 || warn "Rosetta übersprungen."
fi

# ---- Funktionen: parallele Subsysteme ----
setup_omz() {
  export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
  [ -d "$ZSH" ] || RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  local C="${ZSH_CUSTOM:-$ZSH/custom}"
  [ -d "$C/themes/powerlevel10k" ]            || git clone -q --depth=1 https://github.com/romkatv/powerlevel10k            "$C/themes/powerlevel10k"
  [ -d "$C/plugins/zsh-autosuggestions" ]     || git clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions     "$C/plugins/zsh-autosuggestions"
  [ -d "$C/plugins/zsh-syntax-highlighting" ] || git clone -q --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$C/plugins/zsh-syntax-highlighting"
}

# Kernstück: EINZELNE Paketinstallation mit Fehler-Isolation.
install_packages() {
  set +e
  local d=0 f
  : > "$LOGD/install.fail"
  for f in "${BREWS[@]}"; do
    d=$((d+1)); printf '%s %s formula %s\n' "$d" "$TOTAL" "$f" > "$LOGD/install.status"
    printf '  [%s/%s] %s\n' "$d" "$TOTAL" "$f"
    if brew list --formula --versions "$f" >/dev/null 2>&1; then
      printf '        vorhanden\n'
    elif brew install --formula "$f" >>"$LOGD/install.log" 2>&1; then :
    else echo "$f (formula)" >> "$LOGD/install.fail"; printf '        %s\n' "FEHLGESCHLAGEN -> uebersprungen"; fi
  done
  for f in "${CASKS[@]}"; do
    d=$((d+1)); printf '%s %s cask %s\n' "$d" "$TOTAL" "$f" > "$LOGD/install.status"
    printf '  [%s/%s] %s\n' "$d" "$TOTAL" "$f"
    if brew list --cask --versions "$f" >/dev/null 2>&1; then
      printf '        vorhanden\n'
    elif brew install --cask "$f" >>"$LOGD/install.log" 2>&1; then :
    else echo "$f (cask)" >> "$LOGD/install.fail"; printf '        %s\n' "FEHLGESCHLAGEN -> uebersprungen"; fi
  done
  printf '%s %s done -\n' "$d" "$TOTAL" > "$LOGD/install.status"
  wc -l < "$LOGD/install.fail" | tr -d ' ' > "$LOGD/install.rc"
}

# ---- Dashboard ----
mkbar() { local d=$1 t=$2 w=12 f i s; [ "$t" -gt 0 ] || t=1; f=$(( d*w/t )); [ $f -gt $w ] && f=$w
  s="${GREEN}"; i=0; while [ $i -lt $f ]; do s="$s█"; i=$((i+1)); done
  s="$s${DIM}"; while [ $i -lt $w ]; do s="$s░"; i=$((i+1)); done; printf '%s%s' "$s" "$R"; }
sym_pkg() { local rc
  if [ -f "$LOGD/install.rc" ]; then rc=$(cat "$LOGD/install.rc" 2>/dev/null||echo 0)
    [ "$rc" = 0 ] && printf '%s' "${GREEN}✔${R}" || printf '%s' "${YELLOW}▲${R}"
  else printf '%s' "${CYAN}${FR[$_fri]}${R}"; fi; }
sym_job() { local n="$1" rc
  if [ -f "$LOGD/$n.rc" ]; then rc=$(cat "$LOGD/$n.rc" 2>/dev/null||echo 1)
    [ "$rc" = 0 ] && printf '%s' "${GREEN}✔${R}" || printf '%s' "${YELLOW}▲${R}"
  else printf '%s' "${CYAN}${FR[$_fri]}${R}"; fi; }
dash_row() { local label="$1" name="$2" s line
  s="$(sym_job "$name")"
  line="$(tail -n1 "$LOGD/$name.log" 2>/dev/null | tr -d '\r' | tr -dc '[:print:]' | cut -c1-30)"
  printf '\033[2K%s\n' "${DIM}║${R} $s ${PINK}${label}${R} ${DIM}${line}${R}"; }
dash_draw() {
  [ "$_first" = 0 ] && printf '\033[6A'; _first=0
  local d=0 t=$TOTAL kind cur="…" fails=0 bar
  [ -r "$LOGD/install.status" ] && { read -r d t kind cur < "$LOGD/install.status" 2>/dev/null || true; }
  [ -s "$LOGD/install.fail" ] && fails=$(wc -l < "$LOGD/install.fail" | tr -d ' ')
  bar="$(mkbar "${d:-0}" "${t:-$TOTAL}")"; cur="$(printf '%s' "$cur" | cut -c1-16)"
  printf '\033[2K%s\n' "${DIM}╔══ ${PINK}PARALLEL SUBSYSTEMS${DIM} ═══════════════════════════╗${R}"
  printf '\033[2K%s\n' "${DIM}║${R} $(sym_pkg) ${PINK}PACKAGES${R} $bar ${CYAN}${d}/${t}${R} ${DIM}${cur}${R}$([ "${fails:-0}" -gt 0 ] && printf ' %s' "${RED}✖${fails}${R}")"
  dash_row "SHELL  " omz
  dash_row "CLONES " repos
  dash_row "SYSTEM " macos
  printf '\033[2K%s\n' "${DIM}╚═════════════════════════════════════════════════╝${R}"
}
dashboard() {
  printf '\033[?25l'
  while :; do
    dash_draw
    if [ -f "$LOGD/install.rc" ] && [ -f "$LOGD/omz.rc" ] && [ -f "$LOGD/repos.rc" ] && [ -f "$LOGD/macos.rc" ]; then dash_draw; break; fi
    _fri=$(( (_fri+1) % NF )); sleep 0.12
  done
  printf '\033[?25h'
}

# ---- 4. PARALLEL-PHASE (Fehler hier sind nie fatal) ----
step "Subsysteme starten — Pakete einzeln, Rest parallel"
set +e
rm -f "$LOGD"/*.rc "$LOGD/install.status"; : > "$LOGD/install.log"
( setup_omz                             >"$LOGD/omz.log"   2>&1; echo $? >"$LOGD/omz.rc"   ) & P_OMZ=$!
( "$REPO_DIR/scripts/clone-repos.sh"    >"$LOGD/repos.log" 2>&1; echo $? >"$LOGD/repos.rc" ) & P_REPOS=$!
( "$REPO_DIR/scripts/macos-defaults.sh" >"$LOGD/macos.log" 2>&1; echo $? >"$LOGD/macos.rc" ) & P_MAC=$!
if [ "$TUI" = 1 ]; then
  ( install_packages >"$LOGD/install.log" 2>&1 ) & P_INS=$!
  dashboard
  wait "$P_OMZ" "$P_REPOS" "$P_MAC" "$P_INS" 2>/dev/null
else
  install_packages
  wait "$P_OMZ" "$P_REPOS" "$P_MAC" 2>/dev/null
fi
set -e

# ---- 5. Report der Parallel-Phase ----
step "Ergebnis"
if [ -s "$LOGD/install.fail" ]; then
  N=$(wc -l < "$LOGD/install.fail" | tr -d ' ')
  warn "$N Paket(e) übersprungen — der Rest wurde installiert:"
  while IFS= read -r x; do printf '%s\n' "      ${DIM}· $x${R}"; done < "$LOGD/install.fail"
  { echo "== UEBERSPRUNGENE PAKETE =="; cat "$LOGD/install.fail"; } >> "$LOG"
else ok "Alle $TOTAL Pakete installiert (oder bereits vorhanden)"; fi
RC=$(cat "$LOGD/omz.rc"   2>/dev/null||echo 1); [ "$RC" = 0 ] && ok "Shell (oh-my-zsh)"   || warn "oh-my-zsh mit Fehlern (Log: $LOGD/omz.log)"
RC=$(cat "$LOGD/repos.rc" 2>/dev/null||echo 1); [ "$RC" = 0 ] && ok "Repo-Klone"          || warn "Repo-Klone teils fehlgeschlagen — privat? -> gh auth login, dann ./scripts/clone-repos.sh"
RC=$(cat "$LOGD/macos.rc" 2>/dev/null||echo 1); [ "$RC" = 0 ] && ok "macOS-Defaults"      || warn "macOS-Defaults mit Fehlern (Log: $LOGD/macos.log)"

# ---- 6. Dotfiles (chezmoi — fragt Name/E-Mail) ----
step "Dotfiles anwenden (chezmoi)…"
chezmoi init --apply --source "$REPO_DIR" || warn "chezmoi meldete Fehler — Ausgabe oben / im Log."

# ---- 7. Claude Code ----
step "Claude Code (npm via mise)…"
mise exec -- npm install -g @anthropic-ai/claude-code >>"$LOG" 2>&1 \
  && ok "Claude Code installiert" \
  || warn "Claude Code separat installieren (docs.claude.com/claude-code)."

# ---- Abschluss ----
{ echo "== JOB-LOGS =="; for l in "$LOGD"/*.log; do echo "--- $l ---"; cat "$l" 2>/dev/null; done; } >> "$LOG" 2>/dev/null || true
S=$(( $(date +%s) - START ))
printf '\n%s\n' "${GREEN}   ▟████████████████████████████████████████████▙${R}"
printf '%s\n'   "${GREEN}   █${CYAN}   S Y S T E M   O N L I N E   ·   ${S}s          ${GREEN}█${R}"
printf '%s\n'   "${GREEN}   ▜████████████████████████████████████████████▛${R}"
printf '%s\n' "  ${CYAN}Voll-Log:${R} $LOG"
[ -s "$LOGD/install.fail" ] && printf '%s\n' "  ${YELLOW}Übersprungene Pakete später einzeln: brew install <name>${R}"
cat <<'NEXT'

  Manuelle Restschritte (docs/cheatsheet.md → "Nach dem Setup"):
   • Apple-ID/iCloud · Ghostty öffnen · pass/GPG-Keys · gh auth login
   • tailscale up · Citrix-Store · claude starten + Abo-Login
   • Motion-Key für `morgen`:  pass insert motion/api-key
   • nvim öffnen (Plugins) + :checkhealth · p10k configure
   • Chrome: ./scripts/chrome-extensions.sh · Caps Lock -> Control · FileVault
NEXT
