resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "main-igw"
  }
}