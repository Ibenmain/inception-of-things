#!/bin/bash
set -e

echo "=== WARNING: This will remove Docker, K3d, kubectl, and K3s clusters ==="
read -p "Are you sure you want to continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo "=== Removing K3d cluster ==="
k3d cluster delete iot-cluster 2>/dev/null || echo "No cluster found"

echo "=== Removing K3d ==="
sudo rm -f /usr/local/bin/k3d

echo "=== Removing kubectl ==="
sudo rm -f /usr/local/bin/kubectl

# Remove kubectl aliases from bashrc
sed -i '/alias kubectl='"'"'sudo kubectl'"'"'/d' ~/.bashrc
sed -i '/alias k='"'"'sudo kubectl'"'"'/d' ~/.bashrc

echo "=== Removing Docker ==="
sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt autoremove -y

# Remove Docker repositories and keys
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo rm -f /etc/apt/keyrings/docker.asc

echo "=== Removing Docker group membership ==="
sudo gpasswd -d $USER docker 2>/dev/null || echo "User not in docker group"

echo "=== Removing Kubeconfig files ==="
rm -rf ~/.kube
rm -f ~/.kube/config

echo "=== Removing Docker data (optional) ==="
read -p "Do you want to remove all Docker data (images, containers, volumes)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    echo "Docker data removed"
fi

echo "=== Cleanup completed ==="
echo "NOTE: You may want to log out and log back in to refresh group memberships"