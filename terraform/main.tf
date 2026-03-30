terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC ---

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# --- Security Groups ---

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  my_ip_cidr   = var.my_ip_cidr
}

# --- Bastion Host (public subnet) ---

module "bastion" {
  source = "./modules/bastion"

  project_name      = var.project_name
  ami_id            = var.ami_id
  instance_type     = var.bastion_instance_type
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_groups.bastion_sg_id
  key_name          = var.key_name
}

# --- Private EC2 Instances ---

module "private_instances" {
  source = "./modules/private-instances"

  project_name      = var.project_name
  instance_count    = var.private_instance_count
  ami_id            = var.ami_id
  instance_type     = var.private_instance_type
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.private_sg_id
  key_name          = var.key_name
}
