#!/bin/bash
set -e

# Load configuration
if [ -f "deploy/config.sh" ]; then
    source deploy/config.sh
    echo "Configuration loaded from deploy/config.sh"
else
    echo "Warning: deploy/config.sh not found."
fi

echo "Deleting VM: $INSTANCE_NAME in $ZONE..."
gcloud compute instances delete "$INSTANCE_NAME" --zone="$ZONE" --project="$PROJECT_ID"
echo "VM '$INSTANCE_NAME' deleted successfully."

echo "Deleting Instance Schedule '$VM_SCHEDULE_NAME'..."
gcloud compute resource-policies delete "$VM_SCHEDULE_NAME" --region="$REGION" --project="$PROJECT_ID"
echo "Instance Schedule '$VM_SCHEDULE_NAME' deleted successfully."

echo "Deployment Script Finished."