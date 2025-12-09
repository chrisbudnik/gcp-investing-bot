#!/bin/bash
set -e

# vm_provision.sh
# Run this script INSIDE the VM to provision the environment.
# This installs system-level dependencies.
# It is called by vm_startup.sh

# Prevent interactive prompts during apt install
export DEBIAN_FRONTEND=noninteractive

echo "Starting VM Provisioning..."

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    liblzma-dev \
    tk-dev

cd /tmp/
wget https://www.python.org/ftp/python/3.14.2/Python-3.14.2.tgz
tar xzf Python-3.14.2.tgz
cd Python-3.14.2

sudo ./configure --prefix=/opt/python/3.14.2/ --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi --enable-shared --enable-loadable-sqlite-extensions --with-openssl=/usr/local/ssl
sudo make -j "$(grep -c ^processor /proc/cpuinfo)"
sudo make altinstall
sudo rm /tmp/Python-3.14.2.tgz

sudo ln -s /opt/python/3.14.2/bin/python3.14        /opt/python/3.14.2/bin/python3
sudo ln -s /opt/python/3.14.2/bin/python3.14        /opt/python/3.14.2/bin/python
sudo ln -s /opt/python/3.14.2/bin/pip3.14           /opt/python/3.14.2/bin/pip3
sudo ln -s /opt/python/3.14.2/bin/pip3.14           /opt/python/3.14.2/bin/pip
sudo ln -s /opt/python/3.14.2/bin/pydoc3.14         /opt/python/3.14.2/bin/pydoc
sudo ln -s /opt/python/3.14.2/bin/idle3.14          /opt/python/3.14.2/bin/idle
sudo ln -s /opt/python/3.14.2/bin/python3.14-config   /opt/python/3.14.2/bin/python-config
sudo /opt/python/3.14.2/bin/python3.14 -m pip install --upgrade pip setuptools wheel

sudo /opt/python/3.14.2/bin/python3.14 -m pip install uv


pip3 install --upgrade pip
pip3 install uv


# 3. Check installation
echo "Verifying installations..."
git --version
python3 --version
pip3 --version
uv --version

echo "VM Provisioning complete."