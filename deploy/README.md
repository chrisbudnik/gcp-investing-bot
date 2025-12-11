# Deployment

This directory contains scripts to automate the deployment of the GCP Investing Bot to Google Cloud Platform.

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and initialized.
- Access to a Google Cloud Project.

## File Descriptions

- **`config.sh`**: Central configuration file. Contains variables for Project ID, Region, VM name, Service Account details, etc. Modify this first.
- **`setup_resources.sh`**: One-time setup script. Enables required GCP APIs, creates the Service Account, assigns IAM roles, and creates the backup storage bucket.
- **`vm_create.sh`**: Creates (or updates) the Compute Engine VM instance and sets up the instance schedule (start/stop times).
- **`vm_startup.sh`**: The startup script that runs on the VM. It handles:
  - Cloning/Updating the repository code.
  - Installing Python and dependencies (via `vm_provision.sh` on first run).
  - Setting up and starting systemd services for the bot executor and backend.
- **`vm_provision.sh`**: Helper script used by `vm_startup.sh` to compile Python and install system dependencies on a fresh VM. 
    - Installs Python 3.14.2 from source.
    - Adds UV as Python package manager. 
    - Creates global symlinks for python and pip.
- **`cleanup.sh`**: Deletes the VM and the Instance Schedule.

## Workflow

### 1. Configuration

Open `deploy/config.sh` and set your specific values:

```bash
export PROJECT_ID="your-project-id"
export REGION="us-central1"
# ... other variables
```

### 2. Setup Resources

Run the setup script to prepare your GCP project. This only needs to be run once.

```bash
./deploy/setup_resources.sh
```

### 3. Create VM

Create the VM instance. This will also configure the automatic start/stop schedule.

```bash
./deploy/vm_create.sh
```

Upon creation, the VM will automatically run the `startup-script` (`vm_startup.sh`), which provisions the machine and starts the application.

### 4. Monitoring

You can follow the progress of the startup script and the application logs via GCP Console or `gcloud`:

**Startup Script Logs:**
```bash
# Locally
gcloud compute instances get-serial-port-output investing-bot-vm --zone=us-central1-a

# On the VM
sudo tail -f /var/log/startup-script.log
```

**Application Logs:**
The application runs as systemd services (`trading-bot-executor` and `trading-bot-backend`).

```bash
# SSH into the VM, then:
sudo journalctl -u trading-bot-executor -f
sudo journalctl -u trading-bot-backend -f
```

### 5. Cleanup

To remove the VM and its schedule (typically to save costs or redeploy from scratch):

```bash
./deploy/cleanup.sh
```
