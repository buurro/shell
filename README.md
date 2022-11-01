# Home

My linux shell setup.

## Software needed

- git (to clone this repo)
- [nix](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)

## Usage

```bash
rm ~/.config/nixpkgs/home.nix
git clone git@github.com:buurro/home.git ~/.config/nixpkgs
home-manager switch -b backup
```

### TODO:
- make it macOS compatible (maybe use [nix-darwin](https://github.com/LnL7/nix-darwin))
