# Shell

My macOS + Linux shell setup

## Usage

### macOS

- Set your hostname to something unique in `System Settings > General > About > Name`

- Give the Terminal app permission to manage applications in `System Settings > Privacy & Security > App Management`

- Restart the machine

- Install nix via [the official installer](https://nixos.org/download/) (avoid Determinate Nix)

### Host: smart-blender

### nginx https:

Create a token in the [Cloudflare dashboard](https://dash.cloudflare.com/profile/api-tokens) with the following permissions:
 - Zone.Zone
 - Zone.DNS

Add the token to the file `/var/lib/secrets/cloudflare-blender-acme` :

```
CF_DNS_API_TOKEN=<token>
```

## Credits

Wallpaper: <https://github.com/D3Ext/aesthetic-wallpapers>
