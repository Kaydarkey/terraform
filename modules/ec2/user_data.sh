#!/bin/bash
set -e

# Update system packages
yum update -y

# Install Docker
yum install -y docker
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Pull Docker image
docker pull ${docker_image}

# Run Docker container
docker run -d --name demo-app -p ${docker_host_port}:${docker_container_port} --restart always ${docker_image}

# Install AWS CLI
yum install -y aws-cli

echo "Provisioning complete!"