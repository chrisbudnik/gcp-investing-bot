# Project Configuration
export PROJECT_ID="gcp-investing-bot"
export REGION="us-central1"
export ZONE="us-central1-a"

# Resource Naming
export INSTANCE_NAME="investing-bot-vm"
export SERVICE_ACCOUNT_NAME="sa-investing-bot"
export BACKUP_BUCKET="${PROJECT_ID}-backups"
export REPO_URL="https://github.com/chrisbudnik/gcp-investing-bot.git"

export VM_SCHEDULE_NAME="investing-bot-schedule"
export VM_START_TIME="0 20 * * *"
export VM_STOP_TIME="0 23 * * *"
export VM_TIMEZONE="Europe/Warsaw"

# Service Account Email
export SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# App Directory
export APP_DIR="/opt/investing-bot"
