#!/bin/bash

# startup-script.sh
# This script runs automatically every time the Google Cloud VM boots up.
# It handles:
# 1. Initial bootstrapping (cloning the repo).
# 2. Running the one-time setup (setup_vm.sh) if needed.
# 3. Starting the application services.

REPO_URL="https://github.com/chrisbudnik/gcp-investing-bot.git"
APP_DIR="/opt/investing-bot"

set -e

echo "--- Startup Script Initiated ---"
exec > >(tee /var/log/startup-script.log) 2>&1


# 1. Bootstrap Git (Required to fetch the rest of the scripts)
if ! command -v git &> /dev/null; then
    echo "Installing Git for bootstrap..."
    apt-get update
    apt-get install -y git
fi


# 2. Update/Clone Repository
if [ ! -d "$APP_DIR" ]; then
    echo "Cloning repository to $APP_DIR..."
    git clone "$REPO_URL" "$APP_DIR"
    cd "$APP_DIR"
else
    echo "Updating repository..."
    cd "$APP_DIR"
    git pull
fi


# 3. Load project configuration
if [ -f "deploy/config.sh" ]; then
    source deploy/config.sh
    echo "Configuration loaded from deploy/config.sh"
else
    echo "Warning: deploy/config.sh not found."
fi


# 4. Run Provisioning (setup_vm.sh)
# Check if uv (last step) is installed to determine if provisioning is needed
if ! command -v uv &> /dev/null; then
    echo "Running VM Provisioning..."
    chmod +x deploy/vm_provision.sh
    ./deploy/vm_provision.sh
else
    echo "VM already provisioned. Skipping provisioning step."
fi


# 5. Sync Environment
if pwd | grep -q "$APP_DIR"; then
    echo "In application directory."
else
    echo "Changing to application directory: $APP_DIR"
    cd "$APP_DIR"
fi

echo "Syncing application environment..."
uv sync 


# 6. Define Systemd Services
echo "Configuring Systemd Services..."

# Executor Service
cat <<EOF > /etc/systemd/system/trading-bot-executor.service
[Unit]
Description=Trading Bot Executor
After=network.target

[Service]
User=root
WorkingDirectory=$APP_DIR
# Using uv run to execute in the environment
ExecStart=uv run -m app.bot.executor
Restart=always
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# Backend Service
cat <<EOF > /etc/systemd/system/trading-bot-backend.service
[Unit]
Description=Trading Bot Backend API
After=network.target

[Service]
User=root
WorkingDirectory=$APP_DIR
ExecStart=uv run uvicorn app.backend.main:app --host 0.0.0.0 --port 8000
Restart=always
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# 6. Start Services
echo "Reloading and Starting Services..."
systemctl daemon-reload
systemctl enable trading-bot-executor
systemctl enable trading-bot-backend
systemctl restart trading-bot-executor
systemctl restart trading-bot-backend

echo "--- Startup Script Complete ---"
