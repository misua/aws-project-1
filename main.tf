terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Include modules here
module "vpc" {
  source               = "./modules/vpc"
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  project_name         = "aws-devops-project"
}

module "iam" {
  source       = "./modules/iam"
  project_name = "aws-devops-project"
  bucket_name  = "aws-devops-project-logs"
}

module "ec2" {
  source                  = "./modules/ec2"
  project_name            = "aws-devops-project"
  instance_type           = var.instance_type
  vpc_id                  = module.vpc.vpc_id
  public_subnet_id        = module.vpc.public_subnet_id
  private_subnet_id       = module.vpc.private_subnet_id
  private_subnet_cidr     = var.private_subnet_cidr
  vpc_cidr                = var.vpc_cidr
  ssh_public_key_path     = var.ssh_public_key_path
  private_route_table_id  = module.vpc.private_route_table_id
  home_ip                 = var.home_ip
  ec2_instance_profile_name = module.iam.ec2_instance_profile_name
}

module "s3" {
  source       = "./modules/s3"
  project_name = "aws-devops-project"
  bucket_name  = "aws-devops-project-logs"
}
