{ config, pkgs, lib, inputs, ... }:
{

  options = { };

  config = {
    networking.enableIPv6 = false;
    environment.systemPackages = with pkgs; [
      curl
      gcc
      git
      htop
      vim
      wget
    ];

    security.sudo.wheelNeedsPassword = false;

    ids.uids = {
      jellyfin = 186;
    };
    ids.gids = {
      jellyfin = 186;
    };

    users.users = {
      marco = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
        openssh.authorizedKeys.keys = inputs.self.users.marco.ssh.publicKeys;
      };
      jellyfin = lib.mkIf config.services.jellyfin.enable {
        name = "jellyfin";
        group = "jellyfin";
        uid = config.ids.uids.jellyfin;
      };
    };
    users.groups = {
      jellyfin = lib.mkIf config.services.jellyfin.enable {
        name = "jellyfin";
        gid = config.ids.gids.jellyfin;
      };
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    environment.etc.hosts.mode = "0644";

    time.timeZone = lib.mkDefault "Europe/Rome";

    nix.settings = {
      experimental-features = lib.mkDefault "nix-command flakes";
      trusted-users = [ "root" "@wheel" ];
    };

    system.autoUpgrade = {
      enable = lib.mkDefault true;
      flake = "github:buurro/shell";
      dates = "02:00";
      randomizedDelaySec = "45min";
    };

    nixpkgs.config.allowUnfree = true;
  };
}
