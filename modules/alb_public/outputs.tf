output "alb_dns_name" {
  value = aws_lb.public_alb.dns_name
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.proxy_tg.arn
}