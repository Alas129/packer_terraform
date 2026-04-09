# Packer & Terraform — Mixed OS Fleet with Ansible Controller

This branch updates the Terraform assignment to provision a mixed private fleet in AWS:

- `3` Amazon Linux EC2 instances tagged with `OS=amazon`
- `3` Ubuntu EC2 instances tagged with `OS=ubuntu`
- `1` private Ubuntu EC2 instance that hosts the Ansible controller
- `1` public bastion host used to reach the private subnet

The Ansible playbook targets the six managed EC2 instances and does the following:

- updates and upgrades packages
- installs or updates Docker to the latest package version available from the OS repositories
- verifies the installed Docker version
- reports disk usage for each EC2 instance

## Branch

Work for this assignment was prepared on:

```bash
git checkout -b feature/mixed-os-ansible-fleet
```

## Architecture

```text
Internet
   |
Bastion (public)
   |
Private Subnets
   |-- Ansible Controller (Ubuntu)
   |-- Amazon Linux 1
   |-- Amazon Linux 2
   |-- Amazon Linux 3
   |-- Ubuntu 1
   |-- Ubuntu 2
   |-- Ubuntu 3
```

## Project Structure

```text
Packer_and_Terraform/
├── ansible/
│   ├── ansible.cfg
│   └── playbooks/
│       └── manage-fleet.yml
├── packer/
│   └── amazon-linux-docker.pkr.hcl
├── terraform/
│   ├── ansible-controller.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   ├── templates/
│   │   ├── ansible-controller-user-data.sh.tftpl
│   │   └── ansible-inventory.ini.tftpl
│   └── modules/
└── README.md
```

## Prerequisites

- Terraform `>= 1.5`
- AWS CLI configured with credentials
- An AWS key pair in `us-west-2`
- Optional: a Packer-built Amazon Linux AMI if you want to keep using your custom AMI for the Amazon Linux nodes and bastion

Check your tools:

```bash
terraform version
aws configure
```

## AMI Strategy

- `amazon_linux_ami_id` is used for the bastion and the three Amazon Linux managed nodes.
- The three Ubuntu managed nodes and the Ansible controller use the latest Ubuntu 22.04 AMI discovered by Terraform.

If you already built an Amazon Linux AMI with Packer in this repo, reuse that AMI ID in `terraform.tfvars`.

## Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars` with your values:

```hcl
aws_region                    = "us-west-2"
project_name                  = "packer-tf-lab"
amazon_linux_ami_id           = "ami-0123456789abcdef0"
key_name                      = "packer-tf-key"
my_ip_cidr                    = "203.0.113.10/32"
ubuntu_instance_count         = 3
amazon_linux_instance_count   = 3
ansible_controller_instance_type = "t3.micro"
```

Get your public IP if needed:

```bash
curl -s ifconfig.me
```

## Provision the Infrastructure

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform apply
```

After `terraform apply`, note these outputs:

- `bastion_public_ip`
- `ansible_controller_private_ip`
- `managed_instances`
- `ansible_inventory`

## What Terraform Creates

- `1` VPC with public and private subnets
- `1` bastion host in the public subnet
- `6` managed private EC2 instances
- `1` private Ansible controller

The six managed nodes are tagged with `OS=amazon` or `OS=ubuntu`, and the controller is bootstrapped with:

- Ansible installed
- a dedicated SSH key used to connect to the six managed instances
- `/home/ubuntu/ansible/ansible.cfg`
- `/home/ubuntu/ansible/inventory.ini`
- `/home/ubuntu/ansible/playbooks/manage-fleet.yml`

## Run the Ansible Playbook

SSH to the bastion with agent forwarding enabled:

```bash
ssh-add ~/.ssh/packer-tf-key.pem
ssh -A ec2-user@<bastion_public_ip>
```

From the bastion, SSH to the Ansible controller:

```bash
ssh ubuntu@<ansible_controller_private_ip>
```

Run the playbook from the controller:

```bash
cd ~/ansible
ansible-playbook -i inventory.ini playbooks/manage-fleet.yml
```

## Expected Playbook Behavior

For all six managed EC2 instances, Ansible will:

1. update and upgrade packages
2. install or update Docker
3. ensure Docker is enabled and running
4. print the Docker version
5. print `df -h /` output for disk usage

## Verification

Use Terraform outputs to confirm the resources:

```bash
terraform output managed_instances
terraform output bastion_public_ip
terraform output ansible_controller_private_ip
```

Use tags in the AWS Console to verify the operating systems:

- three instances tagged `OS=amazon`
- three instances tagged `OS=ubuntu`

You can also inspect the rendered inventory locally:

```bash
terraform output -raw ansible_inventory
```

## Cleanup

When you are done:

```bash
terraform destroy
```
