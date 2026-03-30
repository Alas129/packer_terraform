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

output "private_instance_ips" {
  description = "Private IPs of the 6 EC2 instances in the private subnet"
  value       = module.private_instances.private_ips
}

output "private_instance_ids" {
  description = "Instance IDs of the private EC2 instances"
  value       = module.private_instances.instance_ids
}
