#!/bin/bash

set -euo pipefail

echo "========================================"
echo " Azure DevSecOps Host Installation"
echo " Ubuntu 24.04 LTS"
echo "========================================"

echo "[1/8] Updating system..."

sudo apt update
sudo apt upgrade -y

echo "[2/8] Installing required packages..."

sudo apt install -y \
ca-certificates \
curl \
wget \
git \
jq \
unzip \
zip \
gnupg \
lsb-release \
software-properties-common \
openjdk-21-jdk

echo "[3/8] Installing Docker..."

sudo install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo tee /etc/apt/keyrings/docker.asc >/dev/null
fi

sudo chmod a+r /etc/apt/keyrings/docker.asc

cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: noble
Components: stable
Architectures: amd64
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker "$USER"

echo "[4/8] Installing Trivy..."

curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/trivy.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | \
sudo tee /etc/apt/sources.list.d/trivy.list >/dev/null

sudo apt update
sudo apt install -y trivy

echo "[5/8] Creating project directory..."

sudo mkdir -p /opt/devsecops
sudo chown -R "$USER":"$USER" /opt/devsecops

echo "[6/8] Setting SonarQube kernel parameter..."

echo "vm.max_map_count=524288" | sudo tee /etc/sysctl.d/99-sonarqube.conf >/dev/null
sudo sysctl --system

echo "[7/8] Verifying installations..."

echo ""
echo "Java:"
java -version

echo ""
echo "Git:"
git --version

echo ""
echo "Docker:"
sudo docker --version

echo ""
echo "Docker Compose:"
sudo docker compose version

echo ""
echo "Trivy:"
trivy --version

echo "[8/8] Installation completed."

echo ""
echo "========================================"
echo " Host setup completed successfully!"
echo "========================================"
