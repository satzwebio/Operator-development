#!/bin/bash
set -e

# Log file for troubleshooting
LOG_FILE="/tmp/operator_sdk_setup.log"

echo "Starting setup for Operator SDK development..." > $LOG_FILE

# Update system
echo "Updating system..." >> $LOG_FILE
sudo apt update && sudo apt upgrade -y >> $LOG_FILE 2>&1
sudo apt install -y wget curl git unzip tar make jq >> $LOG_FILE 2>&1

# Install Go
GO_VERSION="1.21.1"
echo "Installing Go version $GO_VERSION..." >> $LOG_FILE
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz >> $LOG_FILE 2>&1
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz >> $LOG_FILE 2>&1
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc >> $LOG_FILE 2>&1

# Install Operator SDK
ARCH=$(uname -m)
OS=$(uname | awk '{print tolower($0)}')
SDK_VERSION=$(curl -s https://api.github.com/repos/operator-framework/operator-sdk/releases/latest | jq -r '.tag_name')
echo "Downloading Operator SDK version $SDK_VERSION for $OS/$ARCH..." >> $LOG_FILE
curl -Lo operator-sdk "https://github.com/operator-framework/operator-sdk/releases/download/${SDK_VERSION}/operator-sdk_${OS}_${ARCH}" >> $LOG_FILE 2>&1
chmod +x operator-sdk >> $LOG_FILE 2>&1
sudo mv operator-sdk /usr/local/bin/ >> $LOG_FILE 2>&1

# Install Kubernetes CLI (kubectl)
echo "Installing kubectl..." >> $LOG_FILE
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" >> $LOG_FILE 2>&1
chmod +x kubectl >> $LOG_FILE 2>&1
sudo mv kubectl /usr/local/bin/ >> $LOG_FILE 2>&1

# Install Docker
echo "Installing Docker..." >> $LOG_FILE
sudo apt install -y docker.io >> $LOG_FILE 2>&1
sudo systemctl enable docker >> $LOG_FILE 2>&1
sudo systemctl start docker >> $LOG_FILE 2>&1
sudo usermod -aG docker ubuntu >> $LOG_FILE 2>&1

echo "Setup complete!" >> $LOG_FILE

# Optional: Remove reboot command if you want to manually handle it later
# sudo reboot
