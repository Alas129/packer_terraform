output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.public_ip
}

output "bastion_public_dns" {
  description = "Public DNS of the bastion host"
  value       = module.bastion.public_dns
}

output "managed_instance_private_ips" {
  description = "Private IPs of the six managed EC2 instances"
  value = concat(
    module.amazon_linux_instances.private_ips,
    module.ubuntu_instances.private_ips
  )
}

output "managed_instance_ids" {
  description = "Instance IDs of the six managed EC2 instances"
  value = concat(
    module.amazon_linux_instances.instance_ids,
    module.ubuntu_instances.instance_ids
  )
}

output "managed_instances" {
  description = "Host metadata for the three Amazon Linux and three Ubuntu instances"
  value = concat(
    module.amazon_linux_instances.instances,
    module.ubuntu_instances.instances
  )
}

output "ansible_controller_instance_id" {
  description = "Instance ID of the Ansible controller host"
  value       = aws_instance.ansible_controller.id
}

output "ansible_controller_private_ip" {
  description = "Private IP of the Ansible controller host"
  value       = aws_instance.ansible_controller.private_ip
}

output "ansible_inventory" {
  description = "Rendered inventory for the six managed nodes"
  value       = local.ansible_inventory
}

output "controller_playbook_path" {
  description = "Playbook location on the Ansible controller"
  value       = "/home/ubuntu/ansible/playbooks/manage-fleet.yml"
}
