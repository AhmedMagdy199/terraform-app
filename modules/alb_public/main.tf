resource "aws_lb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [var.security_group_id]

  tags = {
    Name = "public-alb"
  }
}

resource "aws_lb_target_group" "proxy_tg" {
  name     = "proxy-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy_tg.arn
  }
}


resource "aws_lb_target_group_attachment" "proxy_attachments" {
  count            = length(var.proxy_instance_ids)
  target_group_arn = aws_lb_target_group.proxy_tg.arn
  target_id        = var.proxy_instance_ids[count.index]
  port             = 80
}