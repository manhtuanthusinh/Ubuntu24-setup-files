#!/bin/bash

# --- Debian 13 (Trixie) Fresh Install Setup Script ---
set -euo pipefail

echo "============ Starting the Debian cleanup and setup... ============"
sudo apt update && sudo apt upgrade -y

# 1. System Utilities
sudo apt install -y wget curl zip unzip tree git build-essential ca-certificates gnupg lsb-release tmux

# 1.1. Flatpak Setup
echo "============ Installing Flatpak and Flathub... ============"
sudo apt install -y flatpak gnome-software-plugin-flatpak
# Add the Flathub repository (the most popular Flatpak repo)
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 2. System Tools
# Note: Timeshift is in the Debian main repo, so this works fine.
sudo apt install -y timeshift gufw

# 3. GNOME Customization
sudo apt install -y gnome-tweaks gnome-shell-extension-manager

# 4. Programming Languages
# Java 21 is available in Debian 13 (Trixie)
sudo apt install -y openjdk-21-jdk
JAVA_PATH=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
echo "export JAVA_HOME=$JAVA_PATH" >> "$HOME/.bashrc"
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$HOME/.bashrc"

# Python & C/C++
sudo apt install -y python3 python3-pip python3-venv cmake gdb

# 5. Build Tools
# 6. Docker Setup (Debian Specific)
echo "============ Installing Docker (Debian Repo)... ============"
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
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

# 7. VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update && sudo apt install code -y

# 8. Git & SSH (Keeping your existing logic)
git config --global user.name "Tuan Lai"
git config --global user.email "tuanlaimanh20041@gmail.com"

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "tuanlaimanh20041@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
fi
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"

# 9. Cleanup
sudo apt autoremove -y

echo "✅ Debian Setup complete! Log out or Reboot for changes to take effect."
