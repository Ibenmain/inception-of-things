#!/bin/bash
set -e  # Exit on any error

echo "=== Installing Docker ==="
# Update package lists
sudo apt update
# Install prerequisites
sudo apt install -y ca-certificates curl
# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Add current user to docker group (to avoid sudo)
sudo usermod -aG docker $USER
newgrp docker <<EOF  # Activate group change without logout
echo "Docker installed successfully"
EOF

echo "=== Installing K3d ==="
# Download and install K3d
curl -Lo k3d https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-amd64
chmod +x k3d
sudo mv k3d /usr/local/bin/
k3d version

echo "=== Installing kubectl ==="
# Download latest stable kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# Install it
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# Verify
kubectl version --client

echo "=== All installations completed ==="
