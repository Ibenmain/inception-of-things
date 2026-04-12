# use this script to set up Argo CD on a local K3d cluster for development and testing manually.

# Create a K3d cluster with one server node (default)
k3d cluster create iot-cluster

# Verify cluster is running
kubectl cluster-info
kubectl get nodes

# Create namespaces for ArgoCD and development
kubectl create namespace argocd
kubectl create namespace dev

# Install Argo CD in the argocd namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# if you get error: Unable to connect to the server: dial tcp: lookup raw.githubusercontent.com on 127.0.0.53:53: no such host 
# change /etc/resolv.conf to use the nameserver 8.8.8.8

# Wait for all Argo CD pods to be ready (this may take a minute)
kubectl wait --for=condition=ready pods --all -n argocd --timeout=300s

# Expose the Argo CD UI using port forwarding
kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0  8080:443

# Default username: admin
# To get the default password, run: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Open the Argo CD UI in your browser
open http://localhost:8080
