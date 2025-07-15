variable "bucket_name" {
  description = "The name of the S3 bucket to be created"
  type        = string
}

variable "environment" {
  description = "Environment tag (e.g., dev, prod)"
  type        = string
}
