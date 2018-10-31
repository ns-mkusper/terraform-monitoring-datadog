ROLE	:= GEHC-030

SHELL 	  := /bin/bash
STATES    := "$(shell pwd)"/_states
KEYS    := "$(shell pwd)"/_keys
LOGS			:= "$(shell pwd)"/_logs
TERRAFORM := "$(shell pwd)"/modules
ANSIBLE   := "$(shell pwd)"/ansible
PLAYBOOK  := "$(shell pwd)"/tests

INVENTORY_PATH := "$(shell which terraform-inventory)"


all: terraform provision


rebuild: destroy all


init:
	cd "$(TERRAFORM)"								; \
	terraform init								; \

terraform: init
	cd "$(TERRAFORM)" 							; \
	aws-vault exec "$(ROLE)" --assume-role-ttl=60m -- terraform plan   	; \
	aws-vault exec "$(ROLE)" --assume-role-ttl=60m -- terraform apply		\
		-state="$(STATES)/$(ROLE)"_terraform.tfstate 			\
		-var aws_ec2_public_key="$(KEYS)/$(ROLE)"				\
		-auto-approve


provision: #.roles
	cd "$(ANSIBLE)" 							 	; \
	export TF_STATE="$(STATES)/$(ROLE)"_terraform.tfstate 		 	; \
	ansible-playbook --inventory-file="$(INVENTORY_PATH)" playbook.yml


destroy:
	cd "$(TERRAFORM)"							 	; \
	aws-vault exec "$(ROLE)" --assume-role-ttl=60m -- terraform destroy	\
		-state="$(STATES)/$(ROLE)"_terraform.tfstate 			\
		-var aws_ec2_public_key="$(KEYS)/$(ROLE)"				\
		-auto-approve
