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
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              chkconfig docker on
              docker pull nginxdemos/hello
              docker run -d -p 80:80 --restart always --name web-app nginxdemos/hello
              
              # Create a script to upload Docker logs to S3
              cat > /home/ec2-user/upload_logs_to_s3.sh << 'EOL'
              #!/bin/bash
              CONTAINER_ID=$(docker ps -qf "name=web-app")
              LOG_FILE="/tmp/web-app-logs-$(date +%F-%H-%M-%S).log"
              docker logs "$CONTAINER_ID" > "$LOG_FILE" 2>&1
              aws s3 cp "$LOG_FILE" s3://aws-devops-project-logs/web-app-logs/
              rm "$LOG_FILE"
              EOL
              
              # Make the script executable
              chmod +x /home/ec2-user/upload_logs_to_s3.sh
              
              # Schedule the script to run every hour via cron
              echo "0 * * * * /home/ec2-user/upload_logs_to_s3.sh" | crontab -
              EOF

  tags = {
    Name = "${var.project_name}-app"
  }
}
