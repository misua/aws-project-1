# Outputs will be defined here

output "bastion_public_ip" {
  description = "Public IP address of the Bastion host"
  value       = module.ec2.bastion_public_ip
}

output "nat_public_ip" {
  description = "Public IP address of the NAT instance"
  value       = module.ec2.nat_instance_public_ip
}

output "app_private_ip" {
  description = "Private IP address of the App EC2 instance"
  value       = module.ec2.app_private_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for logs"
  value       = module.s3.bucket_name
}

output "ssh_tunnel_command" {
  description = "Command to create an SSH tunnel to access the app via the Bastion host"
  value       = "ssh -i ~/.ssh/id_ed25519 -L 8080:${module.ec2.app_private_ip}:80 ec2-user@${module.ec2.bastion_public_ip}"
}
