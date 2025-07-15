resource "aws_eip" "nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.subnet_id

  tags = {
    Name = "main-nat"
  }
}