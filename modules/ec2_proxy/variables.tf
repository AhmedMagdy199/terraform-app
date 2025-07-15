
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
