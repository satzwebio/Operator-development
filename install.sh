#!/bin/bash
set -e

# Update system
echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y

# Install dependencies
echo "Installing dependencies..."
sudo apt install -y wget curl git unzip tar make jq docker.io


# Define Go version
GO_VERSION="1.21.1"
sudo rm -rf /usr/local/go

# Download Go
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

# Verify installation
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

echo "Setup complete!"
echo "Rebooting..."
sudo reboot
