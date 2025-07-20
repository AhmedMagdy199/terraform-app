data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "backend" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = element(var.subnet_ids, count.index)
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3
    
    # Create app directory
    mkdir -p /home/ec2-user/app
    chown ec2-user:ec2-user /home/ec2-user/app
    
    # Create the Python app
    cat > /home/ec2-user/app/app.py << 'PYEOF'
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import socket

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        hostname = socket.gethostname()
        message = f"Hello from Backend Server: {hostname}!\nThis is a simple HTTP server running on port 8080.\nServer is healthy and responding to requests."
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(message.encode())

    def do_HEAD(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()

if __name__ == "__main__":
    server_address = ("0.0.0.0", 8080)
    httpd = HTTPServer(server_address, SimpleHandler)
    print(f"Backend server starting on 0.0.0.0:8080...")
    httpd.serve_forever()
PYEOF

    # Set permissions
    chown ec2-user:ec2-user /home/ec2-user/app/app.py
    chmod +x /home/ec2-user/app/app.py
    
    # Create systemd service
    cat > /etc/systemd/system/backend-app.service << 'SVCEOF'
[Unit]
Description=Backend Python App
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/python3 /home/ec2-user/app/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SVCEOF

    # Start the service
    systemctl daemon-reload
    systemctl enable backend-app
    systemctl start backend-app
    
    # Log status
    systemctl status backend-app > /var/log/backend-app-status.log
  EOF
  )

  tags = {
    Name = "backend-${count.index + 1}"
    Type = "backend"
  }
}