variable "vpc_id" {}
variable "subnet_ids" {}
variable "security_group_id" {}
variable "proxy_instance_ids" {
  description = "List of proxy EC2 instance IDs to attach to the public ALB target group"
  type        = list(string)
}
