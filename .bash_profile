# Load .bashrc if available
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

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
