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
for pkg in git stow tmux curl wget python3 python3-pip zsh; do
    if ! command_exists "$pkg"; then
        echo "Installing $pkg..."
        eval $PKG_INSTALL "$pkg"
    else
        echo "$pkg is already installed"
    fi
done

# Install fnm (Fast Node Manager)
echo "=== Installing fnm (Fast Node Manager) ==="
if ! command_exists fnm; then
    echo "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash

    # Source fnm in the current shell
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "`fnm env`"

    # Install the latest LTS version of Node.js
    echo "Installing Node.js LTS..."
    fnm install --lts
    fnm default lts-latest

    echo "Node.js installed: $(node -v)"
    echo "npm installed: $(npm -v)"
else
    echo "fnm is already installed"
fi

# Install lazydocker
echo "=== Installing lazydocker ==="
if ! command_exists lazydocker; then
    echo "Installing lazydocker..."
    LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
    mkdir -p "$HOME/.local/bin"
    tar xf lazydocker.tar.gz -C "$HOME/.local/bin" lazydocker
    rm lazydocker.tar.gz
    echo "lazydocker installed to $HOME/.local/bin/lazydocker"
else
    echo "lazydocker is already installed"
fi

# Install lazygit
echo "=== Installing lazygit ==="
if ! command_exists lazygit; then
    echo "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    mkdir -p "$HOME/.local/bin"
    tar xf lazygit.tar.gz -C "$HOME/.local/bin" lazygit
    rm lazygit.tar.gz
    echo "lazygit installed to $HOME/.local/bin/lazygit"
else
    echo "lazygit is already installed"
fi

# Install Neovim using package manager
if command_exists nvim; then
    nvim_version=$(nvim --version | head -n 1 | cut -d ' ' -f 2)
    echo "Neovim version $nvim_version is already installed"
else
    echo "=== Installing Neovim ==="

    # Install Neovim based on the detected package manager
    if [ "$PKG_MANAGER" = "apt-get" ]; then
        # Try to use the Neovim PPA for Ubuntu/Debian for a more recent version
        if command_exists add-apt-repository; then
            echo "Adding Neovim PPA..."
            sudo add-apt-repository -y ppa:neovim-ppa/stable
            sudo apt-get update
        fi
        eval $PKG_INSTALL neovim
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        eval $PKG_INSTALL neovim
    elif [ "$PKG_MANAGER" = "yum" ]; then
        # EPEL repository might be needed for some RHEL/CentOS versions
        if ! rpm -q epel-release > /dev/null; then
            sudo yum install -y epel-release
        fi
        eval $PKG_INSTALL neovim
    fi

    # Verify installation
    if command_exists nvim; then
        nvim_version=$(nvim --version | head -n 1 | cut -d ' ' -f 2)
        echo "Successfully installed Neovim version $nvim_version"
    else
        echo "Warning: Neovim installation via package manager failed."
        echo "You may need to install it manually or build from source."
    fi
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
stow --target="$HOME" --restow nvim
stow --target="$HOME" --restow tmux
stow --target="$HOME" --restow shell-scripts

# Setup Tmux Plugin Manager (TPM) from submodule
echo "=== Setting up Tmux Plugin Manager (TPM) ==="
if [ -d "tmux/.tmux/plugins/tpm" ]; then
    echo "Tmux Plugin Manager submodule is available"
    # Make sure the symlinks are created
    mkdir -p "$HOME/.tmux/plugins"
    echo "Tmux Plugin Manager installed. Press prefix + I inside tmux to install plugins."
else
    echo "Tmux Plugin Manager submodule not found!"
    echo "Please run: git submodule add https://github.com/tmux-plugins/tpm.git tmux/.tmux/plugins/tpm"
    echo "Then run: git submodule init && git submodule update"
fi

# Set up ZSH and Pure prompt
if command_exists zsh; then
    echo "=== Setting up ZSH configuration ==="
    stow --target="$HOME" --restow zsh

    # Set up Pure prompt
    echo "=== Setting up Pure prompt ==="
    bash zsh/.zsh/setup_pure.sh

    # Create private.zsh from example template if it doesn't exist
    if [ ! -f "$HOME/.zsh/private.zsh" ]; then
        echo "Creating private.zsh from example template..."
        mkdir -p "$HOME/.zsh"
        cp "$(dirname "$0")/zsh/.zsh/private.zsh.example" "$HOME/.zsh/private.zsh"
        echo "Created private.zsh file at $HOME/.zsh/private.zsh"
        echo "Please edit this file to add your private environment variables."
    else
        echo "private.zsh already exists, skipping creation"
    fi

    # Install zsh plugins if not already installed
    if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/zsh-autosuggestions"
    else
        echo "zsh-autosuggestions already installed"
    fi

    if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/zsh-syntax-highlighting"
    else
        echo "zsh-syntax-highlighting already installed"
    fi

    # Check if oh-my-zsh is installed, install if not
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Oh My Zsh already installed"
    fi
else
    echo "ZSH is not installed. Skipping ZSH configuration."
    echo "To install ZSH, run: $PKG_INSTALL zsh"
fi

# Set ZSH as default shell if it's not already
if command_exists zsh; then
    echo "=== Setting ZSH as default shell ==="
    CURRENT_SHELL=$(getent passwd $USER | cut -d: -f7)

    if [[ "$CURRENT_SHELL" != *"zsh"* ]]; then
        echo "Changing default shell to ZSH..."
        # Check if zsh is in /etc/shells
        if ! grep -q "$(command -v zsh)" /etc/shells; then
            echo "Adding ZSH to /etc/shells..."
            echo "$(command -v zsh)" | sudo tee -a /etc/shells
        fi

        # Change the default shell
        chsh -s "$(command -v zsh)"

        echo "Default shell changed to ZSH. You'll need to log out and back in for this to take effect."
    else
        echo "ZSH is already your default shell."
    fi
else
    echo "ZSH is not installed. Skipping setting it as default shell."
fi

echo ""
echo "=== Setup complete! ==="
echo "You may need to restart your terminal or run 'source ~/.bashrc' to apply changes."
echo ""
