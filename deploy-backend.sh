#!/bin/bash

# Terraform Backend Setup Script
set -e

echo "Setting up Terraform backend (S3 + DynamoDB)..."

# Check if backend resources already exist
echo "Checking if backend resources already exist..."

# Check S3 bucket
if aws s3 ls s3://lastprojectterraformiti >/dev/null 2>&1; then
    echo "S3 bucket 'lastprojectterraformiti' already exists."
    BUCKET_EXISTS=true
else
    echo "S3 bucket 'lastprojectterraformiti' does not exist."
    BUCKET_EXISTS=false
fi

# Check DynamoDB table
if aws dynamodb describe-table --table-name terraform-state-locks >/dev/null 2>&1; then
    echo "DynamoDB table 'terraform-state-locks' already exists."
    DYNAMODB_EXISTS=true
else
    echo "DynamoDB table 'terraform-state-locks' does not exist."
    DYNAMODB_EXISTS=false
fi

# If both exist, skip creation
if [ "$BUCKET_EXISTS" = true ] && [ "$DYNAMODB_EXISTS" = true ]; then
    echo ""
    echo "Backend resources already exist! Skipping creation."
    echo ""
    echo "Your backend is configured with:"
    echo "  - S3 Bucket: lastprojectterraformiti"
    echo "  - DynamoDB Table: terraform-state-locks"
    echo "  - Region: us-east-1"
    echo ""
    echo "You can now run './deploy.sh' to deploy your infrastructure."
    exit 0
fi

# Create missing resources
echo "Creating missing backend resources..."

# Initialize Terraform for backend setup
terraform init

# Import existing resources if they exist
if [ "$BUCKET_EXISTS" = true ]; then
    echo "Importing existing S3 bucket..."
    terraform import module.dynamodb.aws_s3_bucket.terraform_state lastprojectterraformiti || true
fi

if [ "$DYNAMODB_EXISTS" = true ]; then
    echo "Importing existing DynamoDB table..."
    terraform import module.dynamodb.aws_dynamodb_table.terraform_locks terraform-state-locks || true
fi

# Plan and apply
echo "Planning backend resource creation..."
terraform plan -target=module.dynamodb -var-file="terraform.tfvars" -out=backend-plan

echo "Creating backend resources..."
terraform apply backend-plan

echo ""
echo "Backend setup completed!"
echo ""
echo "Your backend is configured with:"
echo "  - S3 Bucket: lastprojectterraformiti"
echo "  - DynamoDB Table: terraform-state-locks"
echo "  - Region: us-east-1"
echo ""
echo "Next step: Run './deploy.sh' to deploy your infrastructure with state locking."