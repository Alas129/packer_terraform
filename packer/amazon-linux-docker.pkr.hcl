packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "ssh_public_key" {
  type        = string
  description = "Your SSH public key to bake into the AMI"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

source "amazon-ebs" "amazon_linux_docker" {
  ami_name      = "custom-amazon-linux-docker-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"

  tags = {
    Name    = "custom-amazon-linux-docker"
    Builder = "packer"
  }
}

build {
  sources = ["source.amazon-ebs.amazon_linux_docker"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker wget tar",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",

      "NODE_EXPORTER_VERSION=1.8.2",
      "wget -q https://github.com/prometheus/node_exporter/releases/download/v$${NODE_EXPORTER_VERSION}/node_exporter-$${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz",
      "tar -xzf /tmp/node_exporter.tar.gz -C /tmp",
      "sudo mv /tmp/node_exporter-$${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/node_exporter",
      "sudo chown root:root /usr/local/bin/node_exporter",
      "sudo chmod 0755 /usr/local/bin/node_exporter",
      "sudo bash -c 'cat > /etc/systemd/system/node_exporter.service <<\"EOF\"",
      "[Unit]",
      "Description=Prometheus Node Exporter",
      "After=network-online.target",
      "",
      "[Service]",
      "User=ec2-user",
      "Group=ec2-user",
      "Type=simple",
      "ExecStart=/usr/local/bin/node_exporter",
      "Restart=on-failure",
      "",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOF'",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable node_exporter",
      "sudo systemctl start node_exporter",

      "COMPOSE_VERSION=v2.24.0",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/$${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",

      "mkdir -p ~/.ssh",
      "chmod 700 ~/.ssh",
      "echo '${var.ssh_public_key}' >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys",
    ]
  }
}
