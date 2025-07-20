#!/bin/bash

# Terraform Backend Setup Script
set -e

echo "Setting up Terraform backend (S3 + DynamoDB)..."

# Check if we're using setup-backend.tf or if backend is in main.tf
if [ -f "setup-backend.tf" ]; then
    echo "Using setup-backend.tf for backend creation..."
    
    # Step 1: Create backend resources using setup-backend.tf
    echo "Step 1: Creating S3 bucket and DynamoDB table for Terraform backend..."
    terraform init
    terraform plan -target=module.dynamodb -var-file="terraform.tfvars" -out=backend-plan
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
    
else
    echo "setup-backend.tf not found. Checking if backend is configured in main.tf..."
    
    # Check if dynamodb module exists in main.tf
    if grep -q "module.*dynamodb" main.tf; then
        echo "Found dynamodb module in main.tf. Creating backend resources..."
        terraform init
        terraform plan -target=module.dynamodb -var-file="terraform.tfvars" -out=backend-plan
        terraform apply backend-plan
        echo "Backend resources created successfully!"
    else
        echo "Error: No backend configuration found in setup-backend.tf or main.tf"
        echo "Please ensure you have the dynamodb module configured."
        exit 1
    fi
fi