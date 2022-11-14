SHELL_REPO="github:buurro/shell"
SCREENSHOTS_PATH="$HOME/Pictures/screenshots";

set -e

if [[ $OSTYPE == 'darwin'* ]]; then
    if ! command -v brew &> /dev/null; then
        echo "installing homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    if ! command -v nix-env &> /dev/null; then
        echo "installing nix"
        sh <(curl -L https://nixos.org/nix/install)
    fi

    if [ ! -d "$SCREENSHOTS_PATH" ]; then
        echo "creating screenshots directory"
        mkdir -p "$SCREENSHOTS_PATH"
    fi
fi
