create:
	@./aws-hypervisor/scripts/create.sh

deploy:
	@$(MAKE) create init inventory

init:
	@./aws-hypervisor/scripts/init.sh

destroy:
	@./aws-hypervisor/scripts/destroy.sh

start:
	@./aws-hypervisor/scripts/start.sh

stop:
	@./aws-hypervisor/scripts/stop.sh

redeploy-cluster:
	@./openshift-clusters/scripts/redeploy-cluster.sh

shutdown-cluster:
	@./openshift-clusters/scripts/shutdown-cluster.sh

startup-cluster:
	@./openshift-clusters/scripts/startup-cluster.sh

ssh:
	@./aws-hypervisor/scripts/ssh.sh

info:
	@./aws-hypervisor/scripts/print_instance_data.sh

inventory:
	@./aws-hypervisor/scripts/inventory.sh

fencing-ipi:
	@./openshift-clusters/scripts/deploy-fencing-ipi.sh

arbiter-ipi:
	@./openshift-clusters/scripts/deploy-arbiter-ipi.sh

help:
	@echo "Available commands:"
	@echo "  deploy               - Create, initialize, and update inventory for new EC2 instance"
	@echo "  create               - Create new EC2 instance"
	@echo "  init                 - Initialize deployed instance"
	@echo "  start                - Start stopped EC2 instance"
	@echo "  stop                 - Stop running EC2 instance (interactive cluster handling)"
	@echo "  destroy              - Completely destroy EC2 instance and all resources"
	@echo "  redeploy-cluster     - Redeploy OpenShift cluster using dev-scripts make redeploy"
	@echo "  shutdown-cluster     - Shutdown OpenShift cluster VMs in orderly fashion"
	@echo "  startup-cluster      - Start up OpenShift cluster VMs and proxy container"
	@echo "  fencing-ipi          - Deploy fencing IPI cluster (non-interactive)"
	@echo "  arbiter-ipi          - Deploy arbiter IPI cluster (non-interactive)"
	@echo "  ssh                  - SSH into the EC2 instance"
	@echo "  info                 - Display instance information"
	@echo "  inventory            - Update inventory.ini with current instance IP" 