resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for app instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  iam_instance_profile   = var.ec2_instance_profile_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              # Create a script to pull and run the Docker container on boot
              cat > /usr/local/bin/start-app.sh << 'SCRIPT'
              #!/bin/bash
              docker pull nginxdemos/hello
              docker run -d -p 80:80 --restart always nginxdemos/hello
              SCRIPT
              chmod +x /usr/local/bin/start-app.sh
              # Add to crontab to run on reboot
              echo "@reboot /usr/local/bin/start-app.sh" | crontab -
              # Run it now
              /usr/local/bin/start-app.sh
              EOF

  tags = {
    Name = "${var.project_name}-app"
  }
}
