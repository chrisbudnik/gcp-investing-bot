#!/bin/bash
set -e

# vm_provision.sh
# Run this script INSIDE the VM to provision the environment.
# This installs system-level dependencies.
# It is called by vm_startup.sh

# Prevent interactive prompts during apt install
export DEBIAN_FRONTEND=noninteractive

echo "Starting VM Provisioning..."

# 1. Install System Dependencies
echo "Updating apt and installing tools..."
sudo apt-get update
sudo apt-get install -y \
    git \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    jq

# 2. Install uv (Python package manager)
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add to path for this script execution
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Ensure it persists for the user
    # Note: On GCP startup scripts, $HOME might be / (root) or /root.
    if ! grep -q 'source $HOME/.cargo/env' $HOME/.bashrc; then
        echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
    fi
else
    echo "uv is already installed."
fi

# 3. Verification
echo "Verifying installations..."
git --version
python3 --version
uv --version

echo "VM Provisioning complete."
