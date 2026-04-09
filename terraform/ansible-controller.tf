locals {
  target_instances = concat(
    module.amazon_linux_instances.instances,
    module.ubuntu_instances.instances
  )

  ansible_inventory = templatefile("${path.module}/templates/ansible-inventory.ini.tftpl", {
    hosts = local.target_instances
  })

  ansible_cfg      = file("${path.module}/../ansible/ansible.cfg")
  ansible_playbook = file("${path.module}/../ansible/playbooks/manage-fleet.yml")
}

resource "aws_instance" "ansible_controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ansible_controller_instance_type
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.security_groups.private_sg_id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/templates/ansible-controller-user-data.sh.tftpl", {
    private_key = tls_private_key.ansible_controller.private_key_openssh
    public_key  = tls_private_key.ansible_controller.public_key_openssh
    ansible_cfg = local.ansible_cfg
    inventory   = local.ansible_inventory
    playbook    = local.ansible_playbook
  })

  tags = {
    Name = "${var.project_name}-ansible-controller"
    Role = "ansible-controller"
    OS   = "ubuntu"
  }
}
