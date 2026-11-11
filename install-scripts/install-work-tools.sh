#!/bin/bash

# Source utilities
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SOURCE_DIR/utils.sh"

# Install packaged tools in one go; --needed skips the ones already there
install_package just git azure-cli docker kubectl minikube terraform bun deno
ensure_group docker

# Install fnm (Fast Node Manager)
if ! command -v fnm &> /dev/null; then
    echo "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    echo "fnm (Node version manager) installed successfully!"
    
    # Set up fnm environment for this script
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
    
    # Install Node.js LTS
    echo "Installing Node.js LTS..."
    fnm install --lts
    fnm default lts-latest
    echo "Node.js LTS installed and set as default!"
else
    echo "fnm (Node version manager) is already installed."
fi

# Install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
    echo "Installing pyenv..."
    curl -fsSL https://pyenv.run | bash
    echo "pyenv installed successfully!"
else
    echo "pyenv is already installed."
fi

# Install uv
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | bash
    echo "uv installed successfully!"
else
    echo "uv is already installed."
fi

# Install devspace
if ! command -v devspace &> /dev/null; then
    echo "Installing devspace..."
    curl -L -o devspace "https://github.com/loft-sh/devspace/releases/latest/download/devspace-linux-amd64"
    sudo install -c -m 0755 devspace /usr/local/bin
    rm devspace
    echo "devspace installed successfully!"
else
    echo "devspace is already installed."
fi

# Install .NET (multiple versions: 7, 8, 9, 10)
if ! command -v dotnet &> /dev/null || [ ! -d "$HOME/.dotnet" ]; then
    echo "Installing .NET SDK versions 7, 8, 9, and 10..."
    
    # Install dependencies
    echo "Installing .NET dependencies..."
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y libc6 libgcc-s1 libgssapi-krb5-2 libicu-dev libssl-dev libstdc++6 zlib1g
    else
        # For Arch, these packages have different names
        install_package icu krb5 openssl zlib
    fi
    
    # Download and run the dotnet-install script
    curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
    chmod +x dotnet-install.sh
    
    # Install each version
    ./dotnet-install.sh --channel 7.0 --install-dir "$HOME/.dotnet"
    ./dotnet-install.sh --channel 8.0 --install-dir "$HOME/.dotnet"
    ./dotnet-install.sh --channel 9.0 --install-dir "$HOME/.dotnet"
    ./dotnet-install.sh --channel 10.0 --install-dir "$HOME/.dotnet"
    
    rm dotnet-install.sh
    
    echo ".NET SDK 7, 8, 9, and 10 installed successfully!"
else
    echo ".NET is already installed."
    "$HOME/.dotnet/dotnet" --list-sdks 2>/dev/null || dotnet --list-sdks
fi

# Add work-related configurations to .zshrc.local
ZSHRC_LOCAL="$HOME/.zshrc.local"
WORK_MARKER="# >>> work tools setup >>>"

if [ ! -f "$ZSHRC_LOCAL" ] || ! grep -q "$WORK_MARKER" "$ZSHRC_LOCAL"; then
    echo "Creating work tools configuration in .zshrc.local..."
    cat > "$ZSHRC_LOCAL" << 'EOF'
# >>> work tools setup >>>
# Node.js environment (fnm)
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

# Python environment
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# .NET
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$DOTNET_ROOT:$PATH
export PATH=$DOTNET_ROOT:$HOME/.dotnet/tools:$PATH

# devspace aliases and completion
alias random-tag='(echo $RANDOM | md5sum | head -c 20)'
alias force-build='(devspace deploy --var BUILD_NAME=$(random-tag) --force-build)'
source <(devspace completion zsh)

# Docker build environment variables
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
# <<< work tools setup <<<
EOF
    echo "Work tools configuration created in .zshrc.local"
else
    echo "Work tools configuration already exists in .zshrc.local"
fi

echo "All work tools installed successfully!"
