output "private_ips" {
  value = aws_instance.backend[*].private_ip
}


output "instance_ids" {
  value = [for i in aws_instance.backend : i.id]
}