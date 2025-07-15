output "public_alb_dns" {
  description = "Public ALB DNS name for accessing the app"
  value       = module.alb_public.alb_dns_name
}

output "internal_alb_dns" {
  description = "Internal ALB DNS name used by proxies to forward traffic"
  value       = module.alb_internal.alb_internal_dns
}

output "proxy_ips" {
  description = "Public IPs of proxy EC2 instances"
  value       = module.ec2_proxy.public_ips
}

output "backend_private_ips" {
  description = "Private IPs of backend EC2 instances"
  value       = module.ec2_backend.private_ips
}
