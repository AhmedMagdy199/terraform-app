# Backend configuration for Terraform state
# This file should be created after the S3 bucket and DynamoDB table are created

terraform {
  backend "s3" {
    bucket         = "lastprojectterraformiti"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}