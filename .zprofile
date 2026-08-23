# Homebrew (Apple Silicon or Intel) — shellenv sets PATH (bin + sbin) and HOMEBREW_* vars
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Add Rust and Cargo
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi