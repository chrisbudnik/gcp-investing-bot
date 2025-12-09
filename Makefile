.PHONY: setup deploy ssh tunnel start stop logs backup test

PROJECT_ID ?= your-project-id
INSTANCE_NAME ?= trading-bot-vm
ZONE ?= us-central1-a
SERVICE_ACCOUNT ?= trading-bot-sa@$(PROJECT_ID).iam.gserviceaccount.com

setup:
	pip install -r requirements.txt

test:
	pytest

deploy:
	./app/deploy/deploy_app.sh

ssh:
	gcloud compute ssh $(INSTANCE_NAME) --zone=$(ZONE)

tunnel:
	gcloud compute ssh $(INSTANCE_NAME) --zone=$(ZONE) -- -L 8000:localhost:8000

start:
	gcloud compute ssh $(INSTANCE_NAME) --zone=$(ZONE) --command="sudo systemctl start trading-bot-executor trading-bot-backend"

stop:
	gcloud compute ssh $(INSTANCE_NAME) --zone=$(ZONE) --command="sudo systemctl stop trading-bot-executor trading-bot-backend"

logs:
	gcloud compute ssh $(INSTANCE_NAME) --zone=$(ZONE) --command="sudo journalctl -u trading-bot-executor -u trading-bot-backend -f"

backup:
	./app/deploy/backup_db.sh
