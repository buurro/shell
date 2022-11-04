# Home

My linux shell setup.

## Software needed

- git (to clone this repo)
- [nix](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)

## Usage

Add unstable nix channel

```bash
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
nix-channel --update
```

Delete and replace default configuration

```bash
rm ~/.config/nixpkgs/home.nix
git clone --recursive git@github.com:buurro/home.git ~/.config/nixpkgs
```

Apply home-manager config file

```bash
home-manager switch -b backup
```

Set zsh as default shell

```bash
echo ~/.nix-profile/bin/zsh | sudo tee -a /etc/shells
sudo usermod -s ~/.nix-profile/bin/zsh $USER
```

### TODO:

- make it macOS compatible (maybe use [nix-darwin](https://github.com/LnL7/nix-darwin))
