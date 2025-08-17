#!/bin/bash

# Update and upgrade the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
# curl for install the k3s remote
#  openssh-server for connecte with vm
sudo apt-get install -y curl openssh-server

# Generate a new RSA SSH key pair with no passphrase
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
# Add the public key to authorized_keys for passwordless SSH
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

 # Install K3s with custom TLS SAN and kubeconfig permissions
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san 192.168.56.110 --write-kubeconfig-mode 644" sh -

# Save the K3s node token for cluster joining
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/token
 # Copy kubeconfig for external access
cp /etc/rancher/k3s/k3s.yaml /vagrant/k3s.yaml

# Install kubectl using Snap
sudo snap install kubectl --classic
# Create the .kube directory if it doesn't exist
mkdir -p ~/.kube
# Copy kubeconfig to the default location
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
# Set ownership of kubeconfig to the current user
sudo chown $(id -u):$(id -g) ~/.kube/config
# Add KUBECONFIG environment variable to .bashrc
echo "export KUBECONFIG=~/.kube/config" >> ~/.bashrc