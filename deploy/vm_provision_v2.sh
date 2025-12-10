#!/bin/bash
set -e

# vm_provision.sh
# Run this script INSIDE the VM to provision the environment.
# This installs system-level dependencies.
# It is called by vm_startup.sh

# Prevent interactive prompts during apt install
export DEBIAN_FRONTEND=noninteractive

echo "Starting VM Provisioning..."

# sudo apt-get update -y
# sudo apt-get upgrade -y

echo "[Python] Installing build dependencies."
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

# 2. Install Python 3.14.2 from source
# https://www.build-python-from-source.com/

echo "[Python] Downloading and installing Python 3.14.2 from source."

cd /
cd /tmp/
wget https://www.python.org/ftp/python/3.14.2/Python-3.14.2.tgz
tar xzf Python-3.14.2.tgz
cd Python-3.14.2

# 3. Build and install
echo "[Python] Building and installing Python 3.14.2."

sudo ./configure --prefix=/opt/python/3.14.2/ --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi --enable-shared --enable-loadable-sqlite-extensions --with-openssl=/usr/local/ssl
sudo make -j "$(grep -c ^processor /proc/cpuinfo)"
sudo make altinstall
sudo rm /tmp/Python-3.14.2.tgz

# 4. Create symlinks
echo "[Python] Creating symlinks for Python 3.14.2 binaries."

sudo ln -s /opt/python/3.14.2/bin/python3.14        /opt/python/3.14.2/bin/python3
sudo ln -s /opt/python/3.14.2/bin/python3.14        /opt/python/3.14.2/bin/python
sudo ln -s /opt/python/3.14.2/bin/pip3.14           /opt/python/3.14.2/bin/pip3
sudo ln -s /opt/python/3.14.2/bin/pip3.14           /opt/python/3.14.2/bin/pip
sudo ln -s /opt/python/3.14.2/bin/pydoc3.14         /opt/python/3.14.2/bin/pydoc
sudo ln -s /opt/python/3.14.2/bin/idle3.14          /opt/python/3.14.2/bin/idle
sudo ln -s /opt/python/3.14.2/bin/python3.14-config   /opt/python/3.14.2/bin/python-config

# fixes linking err (--enable-shared + custom install path)
echo "/opt/python/3.14.2/lib" | sudo tee /etc/ld.so.conf.d/python-3.14.2.conf
sudo ldconfig

# 5. Update PATH
sudo update-alternatives --install /usr/bin/python python /opt/python/3.14.2/bin/python 2
sudo update-alternatives --install /usr/bin/pip pip /opt/python/3.14.2/bin/pip 2

sudo update-alternatives --config python
sudo update-alternatives --config pip

# 6. Update pip and install uv
echo "[Python] Upgrading pip and installing uv."
pip install --upgrade pip
pip install uv

# 6. Check installation
# echo "Verifying installations..."

# git --version
# python3 --version
# pip3 --version
# uv --version

echo "VM Provisioning complete."