# main.tf
provider "aws" {
  region = var.aws_region
}

# -------------------- VPC --------------------
module "vpc" {
  source = "./modules/vpc"
}

# -------------------- Internet Gateway --------------------
module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
}

# -------------------- NAT Gateway --------------------
module "nat_gateway" {
  source    = "./modules/nat_gateway"
  subnet_id = module.subnets.public_subnets[0]
  depends_on = [module.subnets]
}

# -------------------- Subnets --------------------
module "subnets" {
  source              = "./modules/subnets"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.igw_id
  nat_gateway_id      = module.nat_gateway.nat_id
  depends_on          = [module.internet_gateway]
}

# -------------------- Security Groups --------------------
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# -------------------- Internal ALB (Create first, without targets) --------------------
module "alb_internal" {
  source            = "./modules/alb_internal"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.subnets.private_subnets
  security_group_id = module.security_groups.alb_internal_sg
  backend_instance_ids = []  # Empty initially
  depends_on        = [module.subnets, module.security_groups]
}

# -------------------- EC2 Backend --------------------
module "ec2_backend" {
  source            = "./modules/ec2_backend"
  subnet_ids        = module.subnets.private_subnets
  security_group_id = module.security_groups.backend_sg
  instance_count    = var.backend_instance_count
  key_name          = var.key_name
  bastion_host      = ""  # Will be set after proxy creation
  depends_on        = [module.subnets, module.security_groups]
}

# -------------------- EC2 Proxy --------------------
module "ec2_proxy" {
  source            = "./modules/ec2_proxy"
  subnet_ids        = module.subnets.public_subnets
  security_group_id = module.security_groups.proxy_sg
  instance_count    = var.proxy_instance_count
  key_name          = var.key_name
  internal_alb_dns  = module.alb_internal.alb_internal_dns
  depends_on        = [module.subnets, module.security_groups, module.alb_internal]
}

# -------------------- Public ALB (Create after proxy instances) --------------------
module "alb_public" {
  source             = "./modules/alb_public"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.subnets.public_subnets
  security_group_id  = module.security_groups.alb_sg
  proxy_instance_ids = module.ec2_proxy.instance_ids
  depends_on         = [module.ec2_proxy]
}

# -------------------- Update Proxy with Target Group --------------------
resource "null_resource" "update_proxy_target_group" {
  provisioner "local-exec" {
    command = "echo 'Proxy target group updated'"
  }
  depends_on = [module.alb_public]
}

# Attach proxy instances to public ALB target group
resource "aws_lb_target_group_attachment" "proxy_attachments" {
  count            = length(module.ec2_proxy.instance_ids)
  target_group_arn = module.alb_public.alb_target_group_arn
  target_id        = module.ec2_proxy.instance_ids[count.index]
  port             = 80
  depends_on       = [module.ec2_proxy, module.alb_public]
}

# -------------------- Target Group Attachments --------------------
resource "aws_lb_target_group_attachment" "backend_attachments" {
  count            = length(module.ec2_backend.instance_ids)
  target_group_arn = module.alb_internal.alb_internal_tg_arn
  target_id        = module.ec2_backend.instance_ids[count.index]
  port             = 8080
  depends_on       = [module.ec2_backend, module.alb_internal]
}

# -------------------- Update Backend with Bastion Host --------------------
resource "null_resource" "update_backend_bastion" {
  count = var.backend_instance_count
  
  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("${path.root}/my_key.pem")
    host                = module.ec2_backend.private_ips[count.index]
    bastion_host        = module.ec2_proxy.public_ips[0]
    bastion_user        = "ec2-user"
    bastion_private_key = file("${path.root}/my_key.pem")
  }

  provisioner "file" {
    source      = "${path.root}/app_files/"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3",
      "chmod +x /home/ec2-user/app.py",
      "sudo pkill -f app.py || true",
      "nohup python3 /home/ec2-user/app.py > /home/ec2-user/app.log 2>&1 &",
      "sleep 5",
      "ps aux | grep app.py | grep -v grep"
    ]
  }

  depends_on = [module.ec2_backend, module.ec2_proxy]
}

# -------------------- Save IPs --------------------
resource "null_resource" "save_ips" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Public ALB DNS: ${module.alb_public.alb_dns_name}" > deployment-info.txt
      echo "Internal ALB DNS: ${module.alb_internal.alb_internal_dns}" >> deployment-info.txt
      echo "Proxy Public IPs:" >> deployment-info.txt
      echo "  - ${module.ec2_proxy.public_ips[0]}" >> deployment-info.txt
      echo "  - ${module.ec2_proxy.public_ips[1]}" >> deployment-info.txt
      echo "Backend Private IPs:" >> deployment-info.txt
      echo "  - ${module.ec2_backend.private_ips[0]}" >> deployment-info.txt
      echo "  - ${module.ec2_backend.private_ips[1]}" >> deployment-info.txt
    EOT
  }
  depends_on = [module.ec2_proxy, module.ec2_backend, module.alb_public, module.alb_internal]
}