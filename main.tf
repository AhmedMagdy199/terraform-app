# main.tf
provider "aws" {
  region = "us-east-1"
}

# -------------------- S3 --------------------
# module "s3_backend" {
 # source       = "./modules/s3_backend"
  # bucket_name  = "lastprojectterraformiti"
  # environment  = "dev"
# }

# -------------------- VPC --------------------
module "vpc" {
  source = "./modules/vpc"
}

# -------------------- Subnets --------------------
module "subnets" {
  source              = "./modules/subnets"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.igw_id
  nat_gateway_id      = module.nat_gateway.nat_id  
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
}

# -------------------- Security Groups --------------------
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# -------------------- Public ALB --------------------
module "alb_public" {
  source             = "./modules/alb_public"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.subnets.public_subnets
  security_group_id  = module.security_groups.alb_sg
  proxy_instance_ids = module.ec2_proxy.instance_ids
  depends_on         = [module.ec2_proxy]
}

# -------------------- Internal ALB --------------------
module "alb_internal" {
  source               = "./modules/alb_internal"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.subnets.private_subnets
  security_group_id    = module.security_groups.alb_internal_sg
  backend_instance_ids = module.ec2_backend.instance_ids
  depends_on           = [module.ec2_backend]
}

# -------------------- EC2 Proxy --------------------
module "ec2_proxy" {
  source            = "./modules/ec2_proxy"
  subnet_ids        = module.subnets.public_subnets
  security_group_id = module.security_groups.proxy_sg
  instance_count    = 2
  key_name          = "my_key"
}

# -------------------- EC2 Backend --------------------
module "ec2_backend" {
  source            = "./modules/ec2_backend"
  subnet_ids        = module.subnets.private_subnets
  security_group_id = module.security_groups.backend_sg
  instance_count    = 2
  key_name          = "my_key"
  bastion_host      = module.ec2_proxy.public_ips[0]
}

# -------------------- Save IPs --------------------
resource "null_resource" "save_ips" {
  provisioner "local-exec" {
    command = <<EOT
      echo "public-ip1: ${module.ec2_proxy.public_ips[0]}" > all-ips.txt
      echo "public-ip2: ${module.ec2_proxy.public_ips[1]}" >> all-ips.txt
      echo "private-ip1: ${module.ec2_backend.private_ips[0]}" >> all-ips.txt
      echo "private-ip2: ${module.ec2_backend.private_ips[1]}" >> all-ips.txt
    EOT
  }
  depends_on = [module.ec2_proxy, module.ec2_backend]
}



# apply it after create the s3 bucket

terraform {
  backend "s3" {
    bucket = "lastprojectterraformiti"
    key    = "env/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
