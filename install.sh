NIX_CONFIG_PATH="$HOME/.config/nix"
NIX_CONFIG_FILE="$NIX_CONFIG_PATH/nix.conf"
SHELL_REPO="github:buurro/shell"
SHELL_USER="marco"

if [ ! -d "$NIX_CONFIG_PATH" ]; then
    mkdir -p "$NIX_CONFIG_PATH"
fi

if [ ! -f "$NIX_CONFIG_FILE" ]; then
    echo "creating $NIX_CONFIG_FILE file"
    touch "$NIX_CONFIG_FILE"
fi

current_config="$(grep "^experimental-features" "$NIX_CONFIG_FILE")"

if [ -z "$current_config" ]; then
    echo "adding 'experimental-features' config"
    echo "experimental-features = nix-command flakes" >> "$NIX_CONFIG_FILE"
else
    new_config="$current_config"
    for feature in "nix-command" "flakes"; do
        if [ ! -z "${current_config##*$feature*}" ]; then
            new_config="$new_config $feature"
        fi
    done
    if [ "$current_config" != "$new_config" ]; then
        echo "editing 'experimental-features' config"
        sed -i "s/$current_config/$new_config/" "$NIX_CONFIG_FILE"
    fi
fi

nix build --no-link "$SHELL_REPO#homeConfigurations.$SHELL_USER.activationPackage"
"$(nix path-info $SHELL_REPO#homeConfigurations.$SHELL_USER.activationPackage)"/activate
