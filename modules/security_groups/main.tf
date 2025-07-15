# ALB (Public) Security Group
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Internal ALB Security Group (NEW - must exist to avoid reference errors)
resource "aws_security_group" "alb_internal_sg" {
  name   = "alb-internal-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow HTTP from Proxy"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.proxy_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Proxy Security Group (Public EC2 that acts as bastion + reverse proxy)
resource "aws_security_group" "proxy_sg" {
  name   = "proxy-sg"
  vpc_id = var.vpc_id

  # Allow SSH from your public IP or 0.0.0.0/0 for testing
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP from Public ALB
  ingress {
    description     = "Allow HTTP from Public ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Backend EC2 Security Group
resource "aws_security_group" "backend_sg" {
  name   = "backend-sg"
  vpc_id = var.vpc_id

  # Allow HTTP from Proxy EC2
  ingress {
    description     = "Allow HTTP from Proxy"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.proxy_sg.id]
  }

  # Allow HTTP from Internal ALB
  ingress {
    description     = "Allow HTTP from Internal ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_internal_sg.id]
  }

  # Allow SSH from Proxy (for bastion access)
  ingress {
    description     = "Allow SSH from Proxy"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.proxy_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
