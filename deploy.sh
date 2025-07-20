#!/bin/bash

# Terraform Deployment Script
set -e

echo "Starting Terraform deployment..."

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

echo "Deployment script completed successfully!"