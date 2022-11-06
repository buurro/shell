# Shell

My linux shell setup.

## Software needed

- zsh
- [nix](https://nixos.org/)

## Automatic installation

```bash
curl https://shell.marco.ooo/install.sh | sh
```

## Manual installation

Edit or create `~/.config/nix/nix.conf` and add the following line to enable the `nix` command and nix flakes.

```
experimental-features = nix-command flakes
```

Build the setup and activate it

```bash
nix build --no-link github:buurro/shell#homeConfigurations.marco.activationPackage
"$(nix path-info github:buurro/shell#homeConfigurations.marco.activationPackage)"/activate
```

This will also install `home-manager`. Now you can update using:

```bash
home-manager switch --flake 'github:buurro/shell#marco'
```

### TODO:

- make it macOS compatible (maybe use [nix-darwin](https://github.com/LnL7/nix-darwin))
