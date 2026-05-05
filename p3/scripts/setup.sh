#!/bin/bash
set -e

echo "=== Installing Docker ==="
sudo apt update
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings

# Detect OS and install Docker accordingly
if [ -f /etc/debian_version ]; then
    # For Debian
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
else
    # For Ubuntu
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

echo "=== Docker installed successfully ==="

echo "=== Installing K3d ==="
sudo curl -Lo k3d https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-amd64
sudo chmod +x k3d
sudo sudo mv k3d /usr/local/bin/
sudo k3d version

echo "=== Installing kubectl ==="
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo kubectl version --client

echo "=== All installations completed ==="

# Ask user if they want to proceed with cluster setup
read -p "Do you want to create the K3d cluster and setup ArgoCD? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup completed. Run the script again when ready for cluster setup."
    exit 0
fi

echo "=== Creating K3d cluster ==="
sudo k3d cluster create iot-cluster

# Verify cluster is running
sudo kubectl cluster-info
sudo kubectl get nodes

echo "=== Setting up ArgoCD ==="
# Create namespaces for ArgoCD and development
sudo kubectl create namespace argocd
sudo kubectl create namespace dev

# Install Argo CD in the argocd namespace
sudo kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Fix DNS resolution if needed (check if we're using local DNS)
# if grep -q "nameserver 127.0.0.53" /etc/resolv.conf; then
#     echo "Fixing DNS resolution..."
#     sudo sed -i 's/nameserver 127.0.0.53/nameserver 8.8.8.8/' /etc/resolv.conf
# fi

# Wait for all Argo CD pods to be ready
echo "Waiting for ArgoCD pods to be ready..."
sudo kubectl wait --for=condition=ready pods --all -n argocd --timeout=300s

echo "=== ArgoCD Setup Complete ==="
echo "To access ArgoCD UI, run in a separate terminal:"
echo "kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443"
echo ""
echo "Default username: admin"
echo "To get the password, run:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
echo "Then open: http://localhost:8080"

# Ask if user wants to start port forwarding
read -p "Do you want to start port forwarding now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting port forwarding. Press Ctrl+C to stop..."
    sudo kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443
fi