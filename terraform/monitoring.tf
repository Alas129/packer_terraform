locals {
  prometheus_targets = [for ip in module.private_instances.private_ips : "\"${ip}:9100\""]
}

resource "aws_instance" "monitoring" {
  ami                    = var.ami_id
  instance_type          = var.monitoring_instance_type
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.security_groups.private_sg_id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    sudo mkdir -p /opt/monitoring
    sudo chown ec2-user:ec2-user /opt/monitoring

    cat > /opt/monitoring/prometheus.yml <<'PROMCFG'
    global:
      scrape_interval: 15s

    scrape_configs:
      - job_name: "private-ec2-node-exporter"
        static_configs:
          - targets: [${join(", ", local.prometheus_targets)}]
    PROMCFG

    cat > /opt/monitoring/docker-compose.yml <<'COMPOSE'
    services:
      prometheus:
        image: prom/prometheus:v2.54.1
        container_name: prometheus
        restart: unless-stopped
        ports:
          - "9090:9090"
        volumes:
          - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
          - prometheus_data:/prometheus

      grafana:
        image: grafana/grafana-oss:11.2.0
        container_name: grafana
        restart: unless-stopped
        ports:
          - "3000:3000"
        environment:
          - GF_SECURITY_ADMIN_USER=admin
          - GF_SECURITY_ADMIN_PASSWORD=admin
        volumes:
          - grafana_data:/var/lib/grafana
        depends_on:
          - prometheus

    volumes:
      prometheus_data:
      grafana_data:
    COMPOSE

    cd /opt/monitoring
    sudo docker compose up -d
  EOF

  tags = {
    Name = "${var.project_name}-monitoring"
  }
}
