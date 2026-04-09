resource "aws_instance" "private" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  user_data              = var.user_data

  tags = {
    Name    = "${var.project_name}-${var.name_prefix}-${count.index + 1}"
    OS      = var.os_tag
    Role    = "managed-node"
    SSHUser = var.ssh_user
  }
}
