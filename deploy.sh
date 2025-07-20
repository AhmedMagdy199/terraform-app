#!/bin/bash

# Terraform Deployment Script
set -e

echo "Starting Terraform deployment..."

# Check if backend resources exist
echo "Checking if backend resources exist..."
if ! aws s3 ls s3://lastprojectterraformiti >/dev/null 2>&1; then
    echo "Backend S3 bucket not found. Please run './deploy-backend.sh' first."
    exit 1
fi

if ! aws dynamodb describe-table --table-name terraform-state-locks >/dev/null 2>&1; then
    echo "Backend DynamoDB table not found. Please run './deploy-backend.sh' first."
    exit 1
fi

echo "Backend resources found. Proceeding with deployment..."

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Validate configuration
echo "Validating Terraform configuration..."
terraform validate

# Plan the deployment
echo "Planning Terraform deployment..."
terraform plan -var-file="terraform.tfvars" -out=tfplan

# Apply the deployment
echo "Applying Terraform deployment..."
terraform apply tfplan

# Show outputs
echo "Deployment completed! Here are the outputs:"
terraform output

echo ""
echo "Your infrastructure is now deployed with:"
echo "  - State stored in S3 with versioning enabled"
echo "  - State locking via DynamoDB"
echo "  - Public ALB DNS: $(terraform output -raw public_alb_dns)"
echo ""
echo "Deployment script completed successfully!"