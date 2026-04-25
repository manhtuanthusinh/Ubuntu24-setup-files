#!/bin/bash

# --- Debian 13 (Trixie) Fresh Install Setup Script ---
# run this command:  chmod +x setup_debian.sh && ./setup_debian.sh
set -euo pipefail

echo "============ Starting the Debian cleanup and setup... ============"
sudo apt update && sudo apt upgrade -y

# install drivers and firmware
sudo apt install -y firmware-linux firmware-linux-nonfree firmware-misc-nonfree 

# 1. System Utilities
sudo apt install -y wget curl zip unzip tree git build-essential ca-certificates gnupg tmux vlc htop p7zip-full

# 1.1. Flatpak Setup
echo "============ Installing Flatpak and Flathub... ============"
sudo apt install -y flatpak gnome-software-plugin-flatpak
# Add the Flathub repository (the most popular Flatpak repo)
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 2. System Tools
sudo apt install -y timeshift gufw

# 3. GNOME Customization
sudo apt install -y gnome-tweaks gnome-shell-extension-manager

# 4. Programming Languages (Java 21 & Python)
sudo apt install -y openjdk-21-jdk python3 python3-pip python3-venv cmake gdb
# Thiết lập JAVA_HOME vào .bashrc
JAVA_PATH=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
if ! grep -q "JAVA_HOME" "$HOME/.bashrc"; then
    echo "export JAVA_HOME=$JAVA_PATH" >> "$HOME/.bashrc"
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$HOME/.bashrc"
fi

# Python & C/C++
sudo apt install -y python3 python3-pip python3-venv cmake gdb

# 6. Docker Setup (Debian Specific)
echo "============ Installing Docker (Debian Repo)... ============"
# remove all conflicting packages
sudo apt remove -y docker.io docker-doc docker-compose podman-docker containerd runc || true
# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF	
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# check if docker is running
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group (requires logout to take effect)
sudo usermod -aG docker $USER

# 8. Git & SSH
echo "============ Setting up Git & SSH... ============"
git config --global user.name "Tuan Lai"
git config --global user.email "tuanlaimanh20041@gmail.com"

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "tuanlaimanh20041@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
fi
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"

# 9. Cleanup
echo "============ Cleaning up... ============"
sudo apt autoremove -y

echo "--------------------------------------------------"
echo "📋 Copy this SSH key to your GitHub account:"
cat "$HOME/.ssh/id_ed25519.pub"
echo "--------------------------------------------------"
echo "✅ Debian Setup complete! PLEASE REBOOT your machine."
