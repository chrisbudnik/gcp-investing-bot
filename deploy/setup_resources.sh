#!/bin/bash
set -e

# Load configuration
if [ -f "deploy/config.sh" ]; then
    source deploy/config.sh
    echo "Configuration loaded from deploy/config.sh"
else
    echo "Warning: deploy/config.sh not found."
fi

echo "Setting up Google Cloud Project with gcloud CLI: $PROJECT_ID"
gcloud auth application-default login --project=$PROJECT_ID
gcloud config set project $PROJECT_ID

echo "Service Account: $SERVICE_ACCOUNT_EMAIL"

# 1. Enable Required APIs
echo "Enabling APIs..."
gcloud services enable \
    compute.googleapis.com \
    secretmanager.googleapis.com \
    iam.googleapis.com \
    cloudresourcemanager.googleapis.com \
    storage-component.googleapis.com \
    logging.googleapis.com \
    monitoring.googleapis.com \
    --project "$PROJECT_ID"

# 2. Create Service Account
echo "Creating Service Account..."
if ! gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" --project "$PROJECT_ID" &>/dev/null; then
    gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
        --project "$PROJECT_ID" \
        --display-name "Trading Bot Service Account"
    echo "Service Account created."
else
    echo "Service Account already exists."
fi

# 3. Add Policy Bindings
echo "Adding Policy Bindings..."

# Secret Manager Access
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/secretmanager.secretAccessor" \
    --condition=None --quiet

# Storage Admin (for backups)
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/storage.objectAdmin" \
    --condition=None --quiet

# Logging and Monitoring
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/logging.logWriter" \
    --condition=None --quiet

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/monitoring.metricWriter" \
    --condition=None --quiet


# 4. Create Storage Bucket
echo "Creating Backup Bucket: gs://${BACKUP_BUCKET}"
if ! gsutil ls -b "gs://${BACKUP_BUCKET}" &>/dev/null; then
    gsutil mb -p "$PROJECT_ID" -l "$REGION" "gs://${BACKUP_BUCKET}"
    # Secure the bucket (prevent public access)
    gcloud storage buckets update "gs://${BACKUP_BUCKET}" --public-access-prevention
else
    echo "Bucket gs://${BACKUP_BUCKET} already exists."
fi

echo "Resources setup complete."
