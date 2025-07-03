# dotfiles

My config files

This is a collection of my dotfiles files, managed by stow.

## Setup Instructions

### Prerequisites

- Git
- GNU Stow
- Any additional dependencies for specific configurations

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Initialize and update submodules:

   ```bash
   git submodule init
   git submodule update
   ```

3. Run the setup script:

   ```bash
   ./setup_linux.sh
   ```

4. Use stow to symlink specific configurations (if you didn't use the setup script):

   ```bash
   # Install all configurations
   stow */

   # Or install specific configurations
   stow nvim tmux
   ```
