#!/usr/bin/env zsh
############################
# Shared helpers sourced by install.sh, macOS.sh, brew.sh, and vscode.sh.
# This file is meant to be sourced, not executed directly.
############################

# All backups from a single ./install.sh run land in one timestamped folder.
# install.sh exports BACKUP_DIR so the scripts it calls share the same folder;
# the folder is only created when something actually needs backing up, so
# re-runs that change nothing leave no empty folders behind.
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

# link_with_backup <source> <target>
# Symlink <target> -> <source>. If a real file or folder already exists at
# <target>, it is first moved into $BACKUP_DIR rather than overwritten.
# Safe to re-run: if the link already points at <source>, nothing happens.
link_with_backup() {
    local src="$1"
    local dst="$2"

    if [[ ! -e "$src" ]]; then
        warn "Skipping link for ${dst}: source ${src} does not exist."
        return 0
    fi

    # Already linked to the right place — nothing to do.
    if [[ -L "$dst" && "${dst:A}" == "${src:A}" ]]; then
        info "${dst} is already linked. Skipping."
        return 0
    fi

    # A real file/folder is in the way — move it into the backup folder.
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "${BACKUP_DIR}/${dst:t}"
        info "Backed up existing ${dst:t} to ${BACKUP_DIR}/"
    fi

    ln -sfn "$src" "$dst"
    info "Linked ${dst} -> ${src}"
}
