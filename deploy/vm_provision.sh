#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Starting VM Provisioning..."

echo "[Python] Installing build dependencies."
sudo apt-get update -y
sudo apt-get install -y \
    make build-essential \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm \
    libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev liblzma-dev uuid-dev


# 1. Install Python 3.14.2
# https://www.build-python-from-source.com/
# https://askubuntu.com/questions/891835/what-does-prefix-do-exactly-when-used-in-configure

PYTHON_VERSION=3.14.2
VERSION=3.14
PREFIX=/opt/python/$PYTHON_VERSION

echo "[Python] Downloading Python $PYTHON_VERSION."

cd /tmp
wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
tar xzf Python-$PYTHON_VERSION.tgz
cd Python-$PYTHON_VERSION

echo "[Python] Building Python $PYTHON_VERSION"

sudo ./configure --prefix=$PREFIX --enable-optimizations
make -j"$(nproc)"
sudo make altinstall

sudo rm /tmp/Python-$PYTHON_VERSION.tgz


# 2. Symlinks inside /opt

echo "[Python] Creating internal symlinks."

sudo ln -sf $PREFIX/bin/python$VERSION   $PREFIX/bin/python3
sudo ln -sf $PREFIX/bin/python$VERSION   $PREFIX/bin/python
sudo ln -sf $PREFIX/bin/pip$VERSION      $PREFIX/bin/pip3
sudo ln -sf $PREFIX/bin/pip$VERSION      $PREFIX/bin/pip


# 3. Global PATH exposure

echo "[Python] Registering python/pip with update-alternatives."

sudo update-alternatives --install /usr/bin/python python $PREFIX/bin/python 200
sudo update-alternatives --install /usr/bin/pip    pip    $PREFIX/bin/pip    200

# Make alternatives non-interactive, selecting highest priority
sudo update-alternatives --auto python
sudo update-alternatives --auto pip


# 4. Install uv globally

echo "[Python] Installing uv."

$PREFIX/bin/pip install --upgrade pip
$PREFIX/bin/pip install uv

# Register uv
sudo update-alternatives --install /usr/bin/uv uv $PREFIX/bin/uv 200
sudo update-alternatives --auto uv

echo "VM Provisioning complete."
