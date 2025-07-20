variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
  default     = "my_key"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "proxy_instance_count" {
  description = "Number of proxy instances"
  type        = number
  default     = 2
}

variable "backend_instance_count" {
  description = "Number of backend instances"
  type        = number
  default     = 2
}