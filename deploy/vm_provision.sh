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

# 2. Install uv
pip3 install --upgrade pip
pip3 install uv

# 3. Check installation
echo "Verifying installations..."
git --version
python3 --version
pip3 --version
uv --version

echo "VM Provisioning complete."
