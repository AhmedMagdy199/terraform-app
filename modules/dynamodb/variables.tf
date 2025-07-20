variable "bucket_name" {
  description = "The name of the S3 bucket to store the Terraform state"
  type        = string
}

variable "dynamodb_table" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}