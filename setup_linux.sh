#!/bin/bash

# setup_linux.sh - Setup script for dotfiles on Linux/Raspberry Pi
#
# This script installs necessary dependencies and sets up dotfiles
# using GNU Stow on Linux systems (not all!).

set -e  # Exit on error

echo "=== Dotfiles Setup Script ==="
echo "This will install necessary software and set up your dotfiles."
echo ""

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please don't run this script as root or with sudo."
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect package manager
if command_exists apt-get; then
    PKG_MANAGER="apt-get"
    PKG_UPDATE="sudo apt-get update"
    PKG_INSTALL="sudo apt-get install -y"
    NEOVIM_DEPS="ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip"
elif command_exists dnf; then
    PKG_MANAGER="dnf"
    PKG_UPDATE="sudo dnf check-update || true"  # Returns non-zero if updates available
    PKG_INSTALL="sudo dnf install -y"
    NEOVIM_DEPS="ninja-build gettext libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip"
elif command_exists yum; then
    PKG_MANAGER="yum"
    PKG_UPDATE="sudo yum check-update || true"  # Returns non-zero if updates available
    PKG_INSTALL="sudo yum install -y"
    NEOVIM_DEPS="ninja-build gettext libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip"
else
    echo "Unsupported package manager. This script supports apt-get, dnf, and yum."
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"

# Update package lists
echo "=== Updating package lists ==="
eval $PKG_UPDATE

# Install dependencies
echo "=== Installing dependencies ==="
eval $PKG_INSTALL git stow tmux curl wget python3 python3-pip

# Install Neovim (package versions might be outdated)
if ! command_exists nvim; then
    echo "=== Installing Neovim ==="
    eval $PKG_INSTALL $NEOVIM_DEPS

    # Clone Neovim repository
    if [ ! -d "$HOME/neovim" ]; then
        git clone https://github.com/neovim/neovim.git "$HOME/neovim"
    else
        echo "Neovim repository already exists, updating..."
        cd "$HOME/neovim" && git pull
    fi

    # Build and install Neovim
    cd "$HOME/neovim"
    make CMAKE_BUILD_TYPE=Release
    sudo make install
    cd -
fi


# # Clone dotfiles repository if not already done
# @FIXME will this scirpt be a gist?
# DOTFILES_DIR="$HOME/.dotfiles"
# if [ ! -d "$DOTFILES_DIR" ]; then
#   echo "=== Cloning dotfiles repository ==="
#   git clone https://github.com/yourusername/dotfiles.git "$DOTFILES_DIR"
#   cd "$DOTFILES_DIR"
# else
#   echo "=== Updating dotfiles repository ==="
#   cd "$DOTFILES_DIR"
#   git pull
# fi

# Initialize and update submodules
echo "=== Setting up git submodules ==="
git submodule init
git submodule update

# Use stow to create symlinks
echo "=== Creating symlinks with stow ==="
stow nvim
stow tmux
stow shell-scripts

echo ""
echo "=== Setup complete! ==="
echo "You may need to restart your terminal or run 'source ~/.bashrc' to apply changes."
echo ""
