variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for internal ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for internal ALB"
  type        = string
}

variable "backend_instance_ids" {
  description = "List of backend EC2 instance IDs to attach to the target group"
  type        = list(string)
}
