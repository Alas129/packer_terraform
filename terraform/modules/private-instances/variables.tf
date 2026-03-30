variable "project_name" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 6
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "key_name" {
  type = string
}
