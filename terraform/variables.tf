variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "project_name" {
  type    = string
  default = "packer-tf-lab"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

variable "amazon_linux_ami_id" {
  type        = string
  description = "Amazon Linux AMI ID for the bastion and Amazon Linux managed nodes"
}

variable "key_name" {
  type        = string
  description = "Name of the AWS key pair for SSH access"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR notation (e.g. 203.0.113.10/32)"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "private_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ubuntu_instance_count" {
  type    = number
  default = 3
}

variable "amazon_linux_instance_count" {
  type    = number
  default = 3
}

variable "ansible_controller_instance_type" {
  type    = string
  default = "t3.micro"
}
