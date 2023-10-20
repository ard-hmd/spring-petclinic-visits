#!/bin/bash

# Install Kubectl (tool for managing Kubernetes clusters)
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && mv ./kubectl /usr/local/bin/kubectl

# Install Eksctl (tool for managing Amazon EKS clusters)
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
mv /tmp/eksctl /usr/local/bin

# Install OpenSSL (dependency for the helm package)
yum install -y openssl

# Install Helm (package manager for Kubernetes)
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm ./get_helm.sh

# Install Docker (container management)
#yum install -y docker
#systemctl enable docker
#usermod -aG docker ec2-user
#newgrp docker
#systemctl start docker