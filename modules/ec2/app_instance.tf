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
              yum install -y aws-cli
              service docker start
              usermod -a -G docker ec2-user
              chkconfig docker on
              docker pull nginxdemos/hello
              docker run -d -p 80:80 --restart always --name web-app nginxdemos/hello
              
              # Create a script to upload Nginx access logs to S3
              cat > /home/ec2-user/upload_logs_to_s3.sh << 'EOL'
              #!/bin/bash
              
              # Set up simple logging
              SCRIPT_LOG="/tmp/s3_upload_script.log"
              echo "[$(date)] Starting log upload script" >> "$SCRIPT_LOG"
              
              # Get container ID
              CONTAINER_ID=$(docker ps -qf "name=web-app")
              if [ -z "$CONTAINER_ID" ]; then
                echo "[$(date)] ERROR: web-app container not found" >> "$SCRIPT_LOG"
                exit 1
              fi
              
              # Create log file with timestamp
              LOG_FILE="/tmp/web-app-access-logs-$(date +%F-%H-%M-%S).log"
              
              # Get logs directly from docker logs command (since logs are linked to stdout)
              docker logs "$CONTAINER_ID" > "$LOG_FILE"
              
              # Check if log file has content
              if [ ! -s "$LOG_FILE" ]; then
                echo "[$(date)] WARNING: Log file is empty" >> "$SCRIPT_LOG"
              else
                echo "[$(date)] Successfully captured logs" >> "$SCRIPT_LOG"
              fi
              
              # Upload to S3
              echo "[$(date)] Uploading to S3" >> "$SCRIPT_LOG"
              aws s3 cp "$LOG_FILE" s3://aws-devops-project-logs/web-app-logs/
              
              # Check upload status
              if [ $? -eq 0 ]; then
                echo "[$(date)] Successfully uploaded logs to S3" >> "$SCRIPT_LOG"
              else
                echo "[$(date)] ERROR: Failed to upload logs to S3" >> "$SCRIPT_LOG"
                # Test S3 permissions
                echo "[$(date)] Testing S3 access:" >> "$SCRIPT_LOG"
                aws s3 ls s3://aws-devops-project-logs/ >> "$SCRIPT_LOG" 2>&1
              fi
              
              # Clean up
              rm -f "$LOG_FILE"
              EOL
              
              # Make the script executable
              chmod +x /home/ec2-user/upload_logs_to_s3.sh
              
              # Run the script once to test
              /home/ec2-user/upload_logs_to_s3.sh
              
              # Schedule the script to run every 5 minutes via cron
              echo "*/5 * * * * /home/ec2-user/upload_logs_to_s3.sh" | crontab -
              EOF

  tags = {
    Name = "${var.project_name}-app" 
  }
}
