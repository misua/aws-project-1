#!/bin/bash
# Test Script for AWS DevOps Project
# This script verifies the infrastructure setup and application accessibility.

set -e

echo "Retrieving Terraform outputs..."
BASTION_PUBLIC_IP=$(terraform output -raw bastion_public_ip)
APP_PRIVATE_IP=$(terraform output -raw app_private_ip)
S3_BUCKET=$(terraform output -raw s3_bucket_name)

echo "Testing SSH access to Bastion host..."
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no ec2-user@$BASTION_PUBLIC_IP "echo 'Bastion host is accessible'"

echo "Testing SSH access to App instance via Bastion..."
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no -J ec2-user@$BASTION_PUBLIC_IP ec2-user@$APP_PRIVATE_IP "echo 'App instance is accessible'"

echo "Checking Docker installation on App instance..."
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no -J ec2-user@$BASTION_PUBLIC_IP ec2-user@$APP_PRIVATE_IP "docker --version && docker ps"

echo "Testing S3 bucket access from App instance..."
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no -J ec2-user@$BASTION_PUBLIC_IP ec2-user@$APP_PRIVATE_IP "aws s3 ls s3://$S3_BUCKET"

echo "Testing web app accessibility..."
echo "Starting SSH tunnel in background..."
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no -fN -L 8080:$APP_PRIVATE_IP:80 ec2-user@$BASTION_PUBLIC_IP
echo "Waiting for tunnel to establish..."
sleep 5
echo "Testing HTTP connection to web app..."
curl -s http://localhost:8080 | grep -q "Hello"
if [ $? -eq 0 ]; then
  echo "Web app is accessible!"
else
  echo "Failed to access web app"
  exit 1
fi

# Kill the SSH tunnel
echo "Closing SSH tunnel..."
pkill -f "ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no -fN -L 8080:$APP_PRIVATE_IP:80"

echo "All tests passed! Your infrastructure and application are functioning as expected."
