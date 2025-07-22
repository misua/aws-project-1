variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
  default     = "aws-devops-project"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "home_ip" {
  description = "Your home IP for SSH access"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2"
  type        = string
}

variable "private_route_table_id" {
  description = "ID of the private route table"
  type        = string
}
