deploy:
	@./scripts/deploy.sh

init:
	@./scripts/init.sh

destroy:
	@./scripts/destroy.sh

start:
	@./scripts/start.sh

stop:
	@./scripts/stop.sh

redeploy-cluster:
	@./scripts/redeploy-cluster.sh

shutdown-cluster:
	@./scripts/shutdown-cluster.sh

startup-cluster:
	@./scripts/startup-cluster.sh

ssh:
	@./scripts/ssh.sh

info:
	@./scripts/print_instance_data.sh

help:
	@echo "Available commands:"
	@echo "  deploy               - Deploy new EC2 instance"
	@echo "  init                 - Initialize deployed instance"
	@echo "  start                - Start stopped EC2 instance"
	@echo "  stop                 - Stop running EC2 instance (interactive cluster handling)"
	@echo "  destroy              - Completely destroy EC2 instance and all resources"
	@echo "  redeploy-cluster     - Redeploy OpenShift cluster using dev-scripts make redeploy"
	@echo "  shutdown-cluster     - Shutdown OpenShift cluster VMs in orderly fashion"
	@echo "  startup-cluster      - Start up OpenShift cluster VMs and proxy container"
	@echo "  ssh                  - SSH into the EC2 instance"
	@echo "  info                 - Display instance information"
