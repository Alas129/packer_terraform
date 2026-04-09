output "instance_ids" {
  value = aws_instance.private[*].id
}

output "private_ips" {
  value = aws_instance.private[*].private_ip
}

output "instances" {
  value = [
    for instance in aws_instance.private : {
      id         = instance.id
      name       = instance.tags["Name"]
      private_ip = instance.private_ip
      os_tag     = instance.tags["OS"]
      ssh_user   = instance.tags["SSHUser"]
    }
  ]
}
