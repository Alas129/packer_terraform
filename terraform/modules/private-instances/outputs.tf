output "instance_ids" {
  value = aws_instance.private[*].id
}

output "private_ips" {
  value = aws_instance.private[*].private_ip
}
