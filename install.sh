#!/bin/bash
set -e

# Update system
echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y

# Install dependencies
echo "Installing dependencies..."
sudo apt install -y wget curl git unzip tar make jq docker.io

# Ensure Docker is running
sudo systemctl enable --now docker

# Add user to Docker group (avoiding sudo requirement)
sudo usermod -aG docker $USER
newgrp docker

# Fix Docker socket permissions
echo "Adjusting Docker socket permissions..."
sudo chmod 666 /var/run/docker.sock

# Define Go version
GO_VERSION="1.21.1"
sudo rm -rf /usr/local/go

# Download and install Go
wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

# Set up environment variables
echo "export PATH=\$PATH:/usr/local/go/bin" | sudo tee -a ~/.profile
echo "export GOPATH=\$HOME/go" | sudo tee -a ~/.profile
echo "export PATH=\$PATH:\$GOPATH/bin" | sudo tee -a ~/.profile

# Apply changes
source ~/.profile

# Clean up
rm -f go${GO_VERSION}.linux-amd64.tar.gz

# Verify Go installation
go version

# Install Operator SDK
echo "Installing Operator SDK..."
SDK_VERSION="v1.30.0"
OS="linux"
ARCH="amd64"
curl -Lo operator-sdk "https://github.com/operator-framework/operator-sdk/releases/download/${SDK_VERSION}/operator-sdk_${OS}_${ARCH}"
chmod +x operator-sdk
sudo mv operator-sdk /usr/local/bin/

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify kubectl installation
kubectl version --client

# Install Kind
echo "Installing Kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify Kind installation
kind version

# Restart Docker service
echo "Restarting Docker service..."
sudo systemctl restart docker

# Create Kind cluster
echo "Creating Kind cluster..."
kind create cluster --name my-cluster

# Verify cluster status
kubectl cluster-info --context kind-my-cluster
kubectl get nodes

alias k=kubectl

echo "Setup complete!"
echo "Rebooting..."
sudo reboot
