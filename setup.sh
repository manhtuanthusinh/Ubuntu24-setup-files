#!/bin/bash

# --- Ubuntu Fresh Install Setup Script ---
# Run this with: chmod +x setup.sh && ./setup.sh

set -euo pipefail

echo "============ Starting the big Ubuntu cleanup and setup... ============"
sudo apt update && sudo apt upgrade -y

# 1. System Utilities & Necessities
echo "============ Installing system utilities... ============"
sudo apt install -y wget curl zip unzip tree htop git build-essential ca-certificates gnupg lsb-release tmux

# 2. System Tools (Timeshift & GUFW)
echo "============ Installing backup and firewall tools... ============"
sudo apt install -y timeshift gufw

# 3. GNOME Customization
echo "============ Installing GNOME Tweaks and Extension Manager... ============"
# extension-manager is the modern way to handle extensions without the browser plugin
sudo apt install -y gnome-tweaks gnome-shell-extension-manager

# 4. Programming Languages (Java 21, Python, C/C++)
echo "============ Setting up development environments... ============"
# Java 21
sudo apt install -y openjdk-21-jdk
# Set JAVA_HOME for current user permanently
echo "============ Setting JAVA_HOME... ============"
JAVA_PATH=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
echo "export JAVA_HOME=$JAVA_PATH" >> "$HOME/.profile"
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$HOME/.profile"

# Python setup
sudo apt install -y python3 python3-pip python3-venv

# C/C++ (build-essential already covers gcc/g++, adding cmake/gdb)
sudo apt install -y cmake gdb

# 5. Build Tools (Maven)
echo "============ Installing Maven... ============"
sudo apt install -y maven

# 6. Docker Setup (Official Repository)
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

# 7. VS code install + setup
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update && sudo apt install code

echo "============ Setting up Git and SSH for GitHub... ============"

# Configure Git identity (edit these!)
git config --global user.name "Tuan Lai"
git config --global user.email "tuanlaimanh20041@gmail.com"

# Generate SSH key if it does not exist
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "Generating new SSH key..."
    ssh-keygen -t ed25519 -C "tuanlaimanh20041@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
else
    echo "SSH key already exists. Skipping generation."
fi

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add "$HOME/.ssh/id_ed25519"

# 9. Cleanup
echo " Cleaning up..."
sudo apt autoremove -y
sudo dpkg --remove-architecture i386

# Display public key
echo "📋 Copy this SSH key and add it to GitHub:"
echo "--------------------------------------------------"
cat "$HOME/.ssh/id_ed25519.pub"
echo "--------------------------------------------------"



echo "✅ Setup complete! PLEASE REBOOT your machine to apply all changes (especially Docker)."
