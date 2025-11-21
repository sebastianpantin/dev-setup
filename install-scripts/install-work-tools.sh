#!/bin/bash

# Install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
    echo "Installing pyenv..."
    curl -fsSL https://pyenv.run | bash
    echo "pyenv installed successfully!"
else
    echo "pyenv is already installed."
fi

# Install devspace
if ! command -v devspace &> /dev/null; then
    echo "Installing devspace..."
    curl -L -o devspace "https://github.com/loft-sh/devspace/releases/latest/download/devspace-linux-amd64" && sudo install -c -m 0755 devspace /usr/local/bin
    echo "devspace installed successfully!"
else
    echo "devspace is already installed."
fi

# Add work-related configurations to .zshrc
ZSHRC="$HOME/.zshrc"
WORK_MARKER="# >>> work tools setup >>>"

if [ -f "$ZSHRC" ] && ! grep -q "$WORK_MARKER" "$ZSHRC"; then
    echo "Adding work tools configuration to .zshrc..."
    cat >> "$ZSHRC" << 'EOF'

# >>> work tools setup >>>
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

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
