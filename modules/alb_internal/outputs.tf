output "alb_internal_dns" {
  value = aws_lb.internal_alb.dns_name
}

output "alb_internal_tg_arn" {
  value = aws_lb_target_group.backend_tg.arn
}

