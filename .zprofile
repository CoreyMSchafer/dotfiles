# Set PATHS
if [ -x "/opt/homebrew/bin/brew" ]; then
    # For Apple Silicon Macs
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Set PIPX environment variables
if [ -d "/opt/pipx" ]; then
    export PIPX_HOME="/opt/pipx"
    export PIPX_BIN_DIR="/opt/pipx/bin"
    export PIPX_MAN_DIR="/opt/pipx/share/man"

    export PATH="/opt/pipx/bin:$PATH"
fi

# Add Rust and Cargo
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi