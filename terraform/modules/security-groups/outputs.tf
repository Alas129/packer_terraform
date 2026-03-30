output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "private_sg_id" {
  value = aws_security_group.private.id
}
