variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR notation (e.g. 203.0.113.10/32)"
}
