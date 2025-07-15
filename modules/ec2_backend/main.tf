data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "backend" {
  count                       = var.instance_count
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = element(var.subnet_ids, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name

  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("D:/terraform/terraform_finalLAB/my_key.pem")
    host                = self.private_ip
    bastion_host        = var.bastion_host
    bastion_user        = "ec2-user"
    bastion_private_key = file("D:/terraform/terraform_finalLAB/my_key.pem")
  }

  provisioner "file" {
    source      = "${path.module}/../../app_files/"
    destination = "/home/ec2-user/app"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python3",
      "cd /home/ec2-user/app",
      "nohup python3 app.py &"
    ]
  }
}