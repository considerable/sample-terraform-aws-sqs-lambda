# Makefile for AWS Lambda and Terraform deployment

# Version of tfenv to use
TFENV_VERSION = 1.5.7

# Terraform commands
TERRAFORM = terraform
TERRAFORM_INIT = $(TERRAFORM) init
TERRAFORM_APPLY = $(TERRAFORM) apply
TERRAFORM_CLEAN = $(TERRAFORM) destroy -auto-approve && rm -rf .terraform* terraform*

# Default target
all: terraform_init terraform_apply

# Initialize Terraform
terraform_init:
	@echo "Initializing Terraform..."
	@$(TERRAFORM_INIT)

# Apply Terraform configuration
terraform_apply:
	@echo "Applying Terraform configuration..."
	@$(TERRAFORM_APPLY)

# Clean up Lambda deployment artifacts and Terraform state
clean:
	@echo "Cleaning terraform..."
	@$(TERRAFORM_CLEAN)
	@echo "Cleaning up temporary files in /tmp directory..."
	@rm -f /tmp/payload.{py,zip}

# Install tfenv with the specified version
install_tfenv:
	curl -L -o tfenv https://github.com/tfutils/tfenv/raw/master/bin/tfenv
	chmod +x tfenv
	./tfenv install $(TFENV_VERSION)
	./tfenv use $(TFENV_VERSION)

# Test Lambda with SQS Trigger
sqs_trigger:
	@echo "Testing SQS Trigger..."
	@./test_sqs_trigger.sh

# View Lambda logs
view_logs:
	@echo "Viewing Lambda Logs..."
	@./view_lambda_logs.sh


