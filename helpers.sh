#!/usr/bin/env zsh
############################
# Shared helpers, sourced by the install scripts (not run directly)
############################

# One timestamped backup folder per run, created only if needed
export BACKUP_DIR="${BACKUP_DIR:-${HOME}/.dotfiles_backup/$(date +%Y-%m-%d_%H-%M-%S)}"

info() { print -P "%F{blue}[info]%f $1"; }
warn() { print -P "%F{yellow}[warn]%f $1"; }
error() { print -P "%F{red}[error]%f $1" >&2; }

# Prompt for a manual step, then wait for enter.
pause_for() {
    echo ""
    echo "$1"
    read -r "?Press enter to continue..."
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

    # :A resolves to an absolute path
    if [[ -L "$dst" && "${dst:A}" == "${src:A}" ]]; then
        info "${dst} is already linked. Skipping."
        return 0
    fi

    # Back up a real file that's in the way
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "${BACKUP_DIR}/${dst:t}" # :t = just the filename
        info "Backed up existing ${dst:t} to ${BACKUP_DIR}/"
    fi

    ln -sfn "$src" "$dst"
    info "Linked ${dst} -> ${src}"
}
