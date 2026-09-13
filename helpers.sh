#!/usr/bin/env bash
############################
# Shared helpers, sourced by the install scripts (not run directly).
# Written in the subset zsh and bash share: the Mac scripts are zsh,
# ubuntu/install.sh is bash (zsh isn't installed yet when it runs).
############################

# One timestamped backup folder per run, created only if needed
export BACKUP_DIR="${BACKUP_DIR:-${HOME}/.dotfiles_backup/$(date +%Y-%m-%d_%H-%M-%S)}"

info() { printf '\033[34m[info]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[warn]\033[0m %s\n' "$1"; }
error() { printf '\033[31m[error]\033[0m %s\n' "$1" >&2; }

# Prompt for a manual step, then wait for enter. Skipped under DOTFILES_NO_INPUT
# (test machines) — every caller is a sign-in or a settings import.
pause_for() {
    [[ -n "${DOTFILES_NO_INPUT:-}" ]] && return 0
    echo ""
    echo "$1"
    printf 'Press enter to continue...'
    read -r _
}

# Read a manifest file's entries, skipping comments and blank lines
read_manifest() {
    grep -vE '^#|^$' "$1"
}

# link_with_backup <source> <target>: symlink, backing up any real file
# already at <target>. Skips links that already point at <source>.
link_with_backup() {
    local src="$1"
    local dst="$2"

    if [[ ! -e "$src" ]]; then
        warn "Skipping link for ${dst}: source ${src} does not exist."
        return 0
    fi

    # Already linked to this exact source? (readlink -f resolves the full path)
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        info "${dst} is already linked. Skipping."
        return 0
    fi

    # Back up a real file that's in the way
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "${BACKUP_DIR}/$(basename "$dst")"
        info "Backed up existing $(basename "$dst") to ${BACKUP_DIR}/"
    fi

    ln -sfn "$src" "$dst"
    info "Linked ${dst} -> ${src}"
}
