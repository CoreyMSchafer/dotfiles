#!/usr/bin/env bash
############################
# Security baseline for a fresh Ubuntu VPS. Run once, as root, on first login:
#   1. System update
#   2. Non-root sudo user (root's SSH key is copied to it)
#   3. sshd: keys only, no root login
#   4. Firewall (UFW), fail2ban for sshd, automatic security updates
#   5. Timezone and hostname
#
# Self-contained on purpose (nothing else from the repo is on the box yet):
#   curl -fsSLO https://raw.githubusercontent.com/CoreyMSchafer/dotfiles/master/server/harden.sh
#   bash harden.sh
# Afterwards, log in as the new user and run server/install.sh for the shell setup.
# Safe to re-run: every step checks before changing anything.
############################

set -euo pipefail

info() { printf '\033[34m[info]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[warn]\033[0m %s\n' "$1"; }

[[ $EUID -eq 0 ]] || { echo "Run this as root (it creates the non-root user)." >&2; exit 1; }

read -r -p "Username for the new sudo user: " username
[[ -n "$username" ]] || { echo "A username is required." >&2; exit 1; }
read -r -p "Hostname [$(hostname)]: " new_hostname
new_hostname="${new_hostname:-$(hostname)}"
read -r -p "Timezone [UTC]: " timezone
timezone="${timezone:-UTC}"

# --- System update. Non-interactive keeps existing config files (sshd is
# configured below anyway); needrestart restarts services itself instead of asking.
info "Updating the system..."
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a
apt-get update -qq
apt-get upgrade -y -qq

# --- Non-root user with sudo
if id -u "$username" >/dev/null 2>&1; then
    info "User ${username} already exists. Skipping."
else
    info "Creating user ${username} (you'll be asked for a password — sudo needs one)..."
    adduser --gecos "" "$username"
fi
usermod -aG sudo "$username"

# Root's authorized key (the one the provider installed) becomes the user's, so
# key login works before passwords are switched off below
user_home="$(getent passwd "$username" | cut -d: -f6)"
if [[ -s /root/.ssh/authorized_keys && ! -e "${user_home}/.ssh/authorized_keys" ]]; then
    info "Copying root's SSH key to ${username}..."
    install -d -m 700 -o "$username" -g "$username" "${user_home}/.ssh"
    install -m 600 -o "$username" -g "$username" /root/.ssh/authorized_keys "${user_home}/.ssh/authorized_keys"
elif [[ -e "${user_home}/.ssh/authorized_keys" ]]; then
    info "${username} already has an authorized_keys file. Skipping."
else
    warn "No /root/.ssh/authorized_keys to copy. Add a key for ${username} before relying on key-only login!"
fi

# --- sshd hardening, as a drop-in. Ubuntu's cloud images ship
# sshd_config.d/50-cloud-init.conf; the first value seen wins, so 00- sorts ahead of it.
# AcceptEnv COLORTERM: exact prompt colors over SSH (the client sends it; see settings/ssh-config).
sshd_dropin=/etc/ssh/sshd_config.d/00-hardening.conf
sshd_wanted="PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
KbdInteractiveAuthentication no
AcceptEnv COLORTERM"
if [[ -f "$sshd_dropin" && "$(cat "$sshd_dropin")" == "$sshd_wanted" ]]; then
    info "sshd hardening already in place. Skipping."
else
    info "Hardening sshd (keys only, no root login)..."
    printf '%s\n' "$sshd_wanted" > "$sshd_dropin"
    mkdir -p /run/sshd # sshd -t needs it; absent until the (socket-activated) service has run
    sshd -t
    systemctl restart ssh
fi

# --- Firewall: deny in, allow out, open SSH + HTTP + HTTPS
if ! command -v ufw >/dev/null 2>&1; then
    apt-get -o DPkg::Lock::Timeout=300 install -y -qq ufw
fi
if ufw status | grep -q "^Status: active"; then
    info "UFW is already active. Skipping."
else
    info "Enabling UFW (SSH, 80, 443 open)..."
    ufw default deny incoming >/dev/null
    ufw default allow outgoing >/dev/null
    ufw allow OpenSSH >/dev/null
    ufw allow 80/tcp >/dev/null
    ufw allow 443/tcp >/dev/null
    ufw --force enable >/dev/null
fi

# --- fail2ban: ban repeated SSH failures, through UFW so bans show up in one place
jail_local=/etc/fail2ban/jail.local
jail_wanted="[DEFAULT]
banaction = ufw

[sshd]
enabled = true
maxretry = 3
bantime = 1h
findtime = 10m"
if [[ -f "$jail_local" && "$(cat "$jail_local")" == "$jail_wanted" ]]; then
    info "fail2ban is already configured. Skipping."
else
    info "Installing and configuring fail2ban..."
    apt-get -o DPkg::Lock::Timeout=300 install -y -qq fail2ban
    printf '%s\n' "$jail_wanted" > "$jail_local"
    systemctl enable --now fail2ban >/dev/null 2>&1
    systemctl restart fail2ban
fi

# --- Automatic security updates (what `dpkg-reconfigure unattended-upgrades` writes)
auto_upgrades=/etc/apt/apt.conf.d/20auto-upgrades
if [[ -f "$auto_upgrades" ]] && grep -q 'Unattended-Upgrade "1"' "$auto_upgrades"; then
    info "Automatic security updates already enabled. Skipping."
else
    info "Enabling automatic security updates..."
    apt-get -o DPkg::Lock::Timeout=300 install -y -qq unattended-upgrades
    printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";\n' > "$auto_upgrades"
fi

# --- Timezone and hostname
if [[ "$(timedatectl show -p Timezone --value)" == "$timezone" ]]; then
    info "Timezone is already ${timezone}. Skipping."
else
    info "Setting timezone to ${timezone}..."
    timedatectl set-timezone "$timezone"
fi
if [[ "$(hostname)" == "$new_hostname" ]]; then
    info "Hostname is already ${new_hostname}. Skipping."
else
    info "Setting hostname to ${new_hostname}..."
    hostnamectl set-hostname "$new_hostname"
fi
# Debian/Ubuntu convention: the hostname resolves locally via 127.0.1.1
grep -qE "^127\.0\.1\.1[[:space:]]+${new_hostname}\b" /etc/hosts || printf '127.0.1.1 %s\n' "$new_hostname" >> /etc/hosts

echo ""
info "Hardening complete."
info "BEFORE closing this session, open a NEW terminal and confirm you can log in:"
info "  ssh ${username}@$(hostname -I | awk '{print $1}')"
info "If that works, root and password logins are safely off. Then, as ${username}:"
info "  sudo apt-get install -y git && git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles && ~/dotfiles/server/install.sh"
