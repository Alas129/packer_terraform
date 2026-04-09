terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "ansible_controller" {
  algorithm = "ED25519"
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
  ami_id            = var.amazon_linux_ami_id
  instance_type     = var.bastion_instance_type
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_groups.bastion_sg_id
  key_name          = var.key_name
}

# --- Private EC2 Instances ---

module "amazon_linux_instances" {
  source = "./modules/private-instances"

  project_name      = var.project_name
  name_prefix       = "amazon"
  instance_count    = var.amazon_linux_instance_count
  ami_id            = var.amazon_linux_ami_id
  instance_type     = var.private_instance_type
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.private_sg_id
  key_name          = var.key_name
  os_tag            = "amazon"
  ssh_user          = "ec2-user"
  user_data         = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    install -d -m 700 -o ec2-user -g ec2-user /home/ec2-user/.ssh
    touch /home/ec2-user/.ssh/authorized_keys
    grep -qxF '${tls_private_key.ansible_controller.public_key_openssh}' /home/ec2-user/.ssh/authorized_keys || echo '${tls_private_key.ansible_controller.public_key_openssh}' >> /home/ec2-user/.ssh/authorized_keys
    chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
    chmod 600 /home/ec2-user/.ssh/authorized_keys
  EOF
}

module "ubuntu_instances" {
  source = "./modules/private-instances"

  project_name      = var.project_name
  name_prefix       = "ubuntu"
  instance_count    = var.ubuntu_instance_count
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = var.private_instance_type
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.private_sg_id
  key_name          = var.key_name
  os_tag            = "ubuntu"
  ssh_user          = "ubuntu"
  user_data         = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    install -d -m 700 -o ubuntu -g ubuntu /home/ubuntu/.ssh
    touch /home/ubuntu/.ssh/authorized_keys
    grep -qxF '${tls_private_key.ansible_controller.public_key_openssh}' /home/ubuntu/.ssh/authorized_keys || echo '${tls_private_key.ansible_controller.public_key_openssh}' >> /home/ubuntu/.ssh/authorized_keys
    chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
    chmod 600 /home/ubuntu/.ssh/authorized_keys
  EOF
}
