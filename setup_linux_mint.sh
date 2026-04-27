#!/bin/bash

# --- Linux Mint 22.3 (Ubuntu 24.04 Based) Setup Script ---
set -euo pipefail

echo "============ Starting the system cleanup and setup... ============"
sudo apt update && sudo apt upgrade -y

# 1. System Utilities
echo "============ Installing system utilities... ============"
sudo apt install -y wget curl zip unzip tree htop git build-essential ca-certificates gnupg lsb-release tmux

# 2. Programming Languages
echo "============ Setting up Java 21, Python, C++... ============"
sudo apt install -y openjdk-21-jdk python3 python3-pip python3-venv cmake gdb

# 3. Java Environment Variables
# We use .bashrc for Mint to ensure it loads in every terminal session
echo "============ Setting JAVA_HOME... ============"
JAVA_PATH=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
if ! grep -q "JAVA_HOME" "$HOME/.bashrc"; then
    echo "export JAVA_HOME=$JAVA_PATH" >> "$HOME/.bashrc"
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$HOME/.bashrc"
fi

# 4. Docker Setup (Official Repository)
# Add Docker's official GPG key:
echo "============ Installing Docker... ============"
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# check if docker is running
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group (requires logout to take effect)
sudo usermod -aG docker $USER

# 5. Git & SSH
echo "============ Setting up Git and SSH... ============"
git config --global user.name "Tuan Lai"
git config --global user.email "tuanlaimanh20041@gmail.com"

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "tuanlaimanh20041@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
fi

# 6. Cleanup
echo "============ Finalizing... ============"
sudo apt autoremove -y

echo "--------------------------------------------------"
echo "📋 Add this SSH key to GitHub (https://github.com/settings/keys):"
cat "$HOME/.ssh/id_ed25519.pub"
echo "--------------------------------------------------"
echo "✅ Setup complete! PLEASE REBOOT to apply Docker group changes."
