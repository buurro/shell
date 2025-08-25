# Shell

My macOS + Linux shell setup

## Usage

### macOS

- Set your hostname to something unique in `System Settings > General > About > Name`
- Install nix via [the official installer](https://nixos.org/download/) (avoid Determinate Nix)
- Install [Homebrew](https://brew.sh/)
- Run darwin-rebuild:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin/master#darwin-rebuild -- switch --flake github:buurro/shell
```

### Host: blender

### nginx https

Create a token in the [Cloudflare dashboard](https://dash.cloudflare.com/profile/api-tokens) with the following permissions:

- Zone.Zone
- Zone.DNS

Add the token to the file `/var/lib/secrets/cloudflare-blender-acme` :

```
CF_DNS_API_TOKEN=<token>
```

## Credits

Wallpaper: <https://github.com/D3Ext/aesthetic-wallpapers>
