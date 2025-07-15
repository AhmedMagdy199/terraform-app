output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

output "alb_internal_sg" {
  value = aws_security_group.alb_internal_sg.id
}

output "proxy_sg" {
  value = aws_security_group.proxy_sg.id
}

output "backend_sg" {
  value = aws_security_group.backend_sg.id
}
