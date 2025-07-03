#!/bin/bash

# Setup script for Pure prompt theme
# This follows the manual installation method from the Pure documentation

# Create directory for Pure if it doesn't exist
mkdir -p "$HOME/.zsh"

# Clone the Pure repository
if [ ! -d "$HOME/.zsh/pure" ]; then
  echo "Cloning Pure prompt repository..."
  git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
else
  echo "Pure prompt repository already exists, updating..."
  cd "$HOME/.zsh/pure" && git pull
fi

echo "Pure prompt setup complete!"
