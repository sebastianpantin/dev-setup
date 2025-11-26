#!/bin/bash

# Source utilities
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SOURCE_DIR/utils.sh"

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

# Install Azure CLI
if ! command -v az &> /dev/null; then
    echo "Installing Azure CLI..."
    install_package azure-cli
    echo "Azure CLI installed successfully"
else
    echo "Azure CLI is already installed"
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

# Install docker
if ! command -v docker &> /dev/null; then
    echo "Installing docker..."
    install_package docker 
    # Add user to docker group
    echo "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    echo "Docker installed successfully! You'll need to log out and back in for group changes to take effect."
else
    echo "docker is already installed."
    # Check if user is in docker group
    if ! groups "$USER" | grep -q docker; then
        echo "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER"
echo "You'll need to log out and back in for group changes to take effect."
    fi
fi

# Install kubectl
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/v1.34.0/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "kubectl installed successfully!"
else
    echo "kubectl is already installed."
fi

# Install minikube
if ! command -v minikube &> /dev/null; then
    echo "Installing minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/v1.33.1/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/bin/minikube && rm minikube-linux-amd64
    echo "minikube installed successfully!"
else
    echo "minikube is already installed."
fi

# Install terraform
if ! command -v terraform &> /dev/null; then
    echo "Installing terraform..."
    install_package terraform
    echo "terraform installed successfully!"
else
    echo "terraform is already installed."
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
        install_package icu
        install_package krb5
        install_package openssl
        install_package zlib
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

# Add work-related configurations to .zshrc
ZSHRC="$HOME/.zshrc"
WORK_MARKER="# >>> work tools setup >>>"

if [ -f "$ZSHRC" ] && ! grep -q "$WORK_MARKER" "$ZSHRC"; then
    echo "Adding work tools configuration to .zshrc..."
    cat >> "$ZSHRC" << 'EOF'

# >>> work tools setup >>>
# Python environment
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# .NET
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$HOME/.dotnet/tools

# devspace aliases and completion
alias random-tag='(echo $RANDOM | md5sum | head -c 20)'
alias force-build='(devspace deploy --var BUILD_NAME=$(random-tag) --force-build)'
source <(devspace completion zsh)

# Docker build environment variables
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
# <<< work tools setup <<<
EOF
    echo "Work tools configuration added to .zshrc"
else
    echo "Work tools configuration already exists in .zshrc"
fi

echo "All work tools installed successfully!"
