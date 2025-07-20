#!/bin/bash

# Terraform Backend Setup Script
set -e

echo "Setting up Terraform backend (S3 + DynamoDB)..."

# Step 1: Create backend resources
echo "Step 1: Creating S3 bucket and DynamoDB table for Terraform backend..."
terraform init
terraform plan -target=module.terraform_backend -var-file="terraform.tfvars" -out=backend-plan
terraform apply backend-plan

echo "Backend resources created successfully!"

# Step 2: Get backend configuration
echo "Step 2: Getting backend configuration..."
terraform output backend_config

echo ""
echo "Backend setup completed!"
echo ""
echo "Next steps:"
echo "1. The S3 bucket and DynamoDB table have been created"
echo "2. Now you can run './deploy.sh' to deploy your infrastructure with state locking"
echo ""
echo "Your backend is configured with:"
echo "  - S3 Bucket: lastprojectterraformiti"
echo "  - DynamoDB Table: terraform-state-locks"
echo "  - Region: us-east-1"