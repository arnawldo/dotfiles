# Platform-specific configurations

# Detect the platform
platform="unknown"
case "$(uname)" in
  "Darwin")
    platform="mac"
    ;;
  "Linux")
    platform="linux"
    ;;
  "MINGW"*|"MSYS"*|"CYGWIN"*)
    platform="windows"
    ;;
esac

# Mac-specific configurations
if [[ "$platform" == "mac" ]]; then
  # Homebrew
  if [[ -d "/opt/homebrew" ]]; then
    # Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -d "/usr/local/Homebrew" ]]; then
    # Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Linux-specific configurations
if [[ "$platform" == "linux" ]]; then
  # Linuxbrew
  if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi
