
variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "key_name" {
  type = string
}

variable "internal_alb_dns" {
  description = "Internal ALB DNS name for backend routing"
  type        = string
}
variable "target_group_arn" {
  description = "Target group ARN for proxy instances"
  type        = string
  default     = ""
}