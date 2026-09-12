# Server

For a fresh Ubuntu VPS. Two scripts, run in order:

1. `harden.sh`, as root, on the first login. The security baseline: system
   update, a non-root sudo user with root's SSH key, sshd locked to keys only
   with root login off, UFW (SSH, 80, 443), fail2ban for sshd, automatic
   security updates, timezone, hostname. It's self-contained, so it can be
   fetched on its own before the repo exists on the box:
   ```sh
   curl -fsSLO https://raw.githubusercontent.com/CoreyMSchafer/dotfiles/master/server/harden.sh
   bash harden.sh
   ```
   Before closing the root session, open a new terminal and confirm the new
   user can log in. That's the only login that will work afterwards.
2. `install.sh`, as the new user. The same shell setup as everywhere else
   (zsh, prompt, aliases, bat, eza, fzf...) with a short `apt.txt` and none of
   the dev toolchain.
   ```sh
   sudo apt-get install -y git && git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles && ~/dotfiles/server/install.sh
   ```

Both are safe to re-run.

Left out on purpose, both easy to add by hand afterwards:

-  fail2ban's `ignoreip` for your own address (`/etc/fail2ban/jail.local`,
   under `[DEFAULT]`). Home IPs change, and it doesn't belong in a public repo.
-  Automatic reboots for kernel updates
   (`Unattended-Upgrade::Automatic-Reboot` in
   `/etc/apt/apt.conf.d/50unattended-upgrades`). Many prefer to reboot during
   a maintenance window.

Web server, database, and app deployment are per-project, not dotfiles.
`../.bash_server_prompt` is the older, standalone prompt for servers that
stay on bash (e.g. during a tutorial).
