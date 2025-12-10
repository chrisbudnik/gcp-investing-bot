#!/bin/bash
set -e

# Load configuration
if [ -f "deploy/config.sh" ]; then
    source deploy/config.sh
    echo "Configuration loaded from deploy/config.sh"
else
    echo "Warning: deploy/config.sh not found."
fi

echo "Creating VM: $INSTANCE_NAME in $ZONE..."

# 1. Create Instance Schedule
echo "Checking/Creating Instance Schedule '$VM_SCHEDULE_NAME'..."
if ! gcloud compute resource-policies describe "$VM_SCHEDULE_NAME" --region="$REGION" --project="$PROJECT_ID" &>/dev/null; then
    gcloud compute resource-policies create instance-schedule "$VM_SCHEDULE_NAME" \
        --description="Schedule for Investing Bot" \
        --region="$REGION" \
        --vm-start-schedule="$VM_START_TIME" \
        --vm-stop-schedule="$VM_STOP_TIME" \
        --timezone="$VM_TIMEZONE" \
        --project="$PROJECT_ID"
    echo "Schedule created."
else
    echo "Schedule '$VM_SCHEDULE_NAME' already exists."
fi

# 2. Create VM Instance
if ! gcloud compute instances describe "$INSTANCE_NAME" --zone="$ZONE" --project="$PROJECT_ID" &>/dev/null; then
    gcloud compute instances create "$INSTANCE_NAME" \
        --project="$PROJECT_ID" \
        --zone="$ZONE" \
        --machine-type=e2-medium \
        --service-account="$SERVICE_ACCOUNT_EMAIL" \
        --scopes=cloud-platform \
        --image-family=debian-11 \
        --image-project=debian-cloud \
        --metadata-from-file startup-script=deploy/vm_startup.sh \
        --resource-policies="$VM_SCHEDULE_NAME" \
        --tags=http-server,https-server

    echo "VM '$INSTANCE_NAME' created successfully."
else
    echo "VM '$INSTANCE_NAME' already exists. Updating startup script metadata..."
    gcloud compute instances add-metadata "$INSTANCE_NAME" \
        --metadata-from-file startup-script=deploy/vm_startup.sh \
        --zone="$ZONE" \
        --project="$PROJECT_ID"
fi

echo "Deployment Script Finished."
