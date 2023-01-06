SHELL_REPO="github:buurro/shell"
SCREENSHOTS_PATH="$HOME/Pictures/screenshots";

set -e

if [[ $OSTYPE == 'darwin'* ]]; then
    if ! command -v brew &> /dev/null; then
        echo "installing homebrew"
        sudo NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    if ! command -v nix-env &> /dev/null; then
        echo "installing nix"
        sh <(curl -L https://nixos.org/nix/install)
        zsh
    fi

    if [ ! -d "$SCREENSHOTS_PATH" ]; then
        echo "creating screenshots directory"
        mkdir -p "$SCREENSHOTS_PATH"
    fi
    cd /tmp
    if ! command -v darwin-rebuild &> /dev/null; then
        FLAKE="$SHELL_REPO#darwinConfigurations.$(hostname -s).system"
        nix --experimental-features 'nix-command flakes' build "$FLAKE"
        ./result/sw/bin/darwin-rebuild switch --flake "$SHELL_REPO"
    else
        darwin-rebuild switch --flake "$SHELL_REPO"
    fi
else
    if ! command -v nix-env &> /dev/null; then
        echo "installing nix"
        sh <(curl -L https://nixos.org/nix/install) --daemon
    fi
    if ! command -v home-manager &> /dev/null; then
        FLAKE="$SHELL_REPO#homeConfigurations.common.activationPackage"
        nix --experimental-features 'nix-command flakes' build --no-link "$FLAKE"
        "$(nix --experimental-features 'nix-command flakes' path-info $FLAKE)"/activate
    else
        home-manager switch --flake "$SHELL_REPO#common"
    fi
fi
