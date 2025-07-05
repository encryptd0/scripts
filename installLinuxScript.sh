#!/bin/bash

set -e

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing core development packages..."
sudo apt install -y curl wget git neovim tmux virtualbox python3 python3-pip default-jdk zsh

# Python Check
if ! command -v python3 &>/dev/null; then
    echo "Python3 not found, something went wrong with the install."
else
    echo "Python3 installed."
fi

# Java Check
if ! java -version &>/dev/null; then
    echo "Java install failed."
else
    echo "Java installed."
fi

# Rust Check & Install
if ! command -v rustc &>/dev/null; then
    echo "Installing Rust..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "Rust is already installed."
fi

# IntelliJ IDEA Community Edition
sudo snap install intellij-idea-community --classic

# VSCode
sudo snap install code --classic

# Postman
sudo snap install postman

# Android Studio
sudo snap install android-studio --classic

# Brave browser
if ! command -v brave-browser &>/dev/null; then
    echo "Installing Brave browser..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave.com/static-assets/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update && sudo apt install brave-browser -y
fi

# Jupyter Notebook
pip3 install --user notebook

# ZSH + Oh My Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
else
    echo "Zsh already set as default shell."
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed."
fi

# RustRover
echo "Downloading RustRover..."
wget -O rustrover.tar.gz "https://download.jetbrains.com/rust/RustRover-2024.1.2.tar.gz"
mkdir -p ~/apps/rustrover
tar -xzf rustrover.tar.gz -C ~/apps/rustrover --strip-components=1
rm rustrover.tar.gz
echo "To run RustRover, use: ~/apps/rustrover/bin/rustrover.sh"

echo ""
echo "All tools installed successfully."
echo "Please restart your terminal or log out/in for shell changes to apply."
