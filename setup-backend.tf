# setup-backend.tf
# This file creates the S3 bucket and DynamoDB table for Terraform backend
# Run this first, then move the backend configuration to main.tf

provider "aws" {
  region = var.aws_region
}

module "dynamodb" {
  source         = "./modules/dynamodb"
  bucket_name    = "lastprojectterraformiti"
  dynamodb_table = "terraform-state-locks"
  
  tags = {
    Environment = var.environment
    Project     = "terraform-infrastructure"
    Purpose     = "terraform-backend"
  }
}

# Output the backend configuration for reference
output "backend_config" {
  value = {
    bucket         = module.dynamodb.bucket_name
    dynamodb_table = module.dynamodb.dynamodb_table_name
    region         = var.aws_region
  }
}