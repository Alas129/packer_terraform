variable "project_name" {
  type = string
}

variable "name_prefix" {
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

variable "os_tag" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "user_data" {
  type    = string
  default = null
}
