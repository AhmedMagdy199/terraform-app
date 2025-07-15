data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "proxy" {
  count                       = var.instance_count
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = element(var.subnet_ids, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = true 

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("D:/terraform/terraform_finalLAB/my_key.pem")
    host        = self.public_ip
  }

 provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo amazon-linux-extras enable nginx1",
      "sudo yum clean metadata",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }
}