# Terraform Backend Module

This module creates:
- An S3 bucket for storing Terraform state files.
- A DynamoDB table for state locking.

## Usage

```hcl
module "backend" {
  source          = "./terraform-backend"
  bucket_name     = "my-terraform-tfstate-bucket"
  dynamodb_table  = "terraform-locks"
  tags = {
    Project = "MyApp"
    Env     = "dev"
  }
}
