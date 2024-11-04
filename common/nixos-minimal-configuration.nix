{ pkgs, lib, inputs, ... }:
{

  options = { };

  config = {
    environment.systemPackages = with pkgs; [
      curl
      gcc
      git
      htop
      vim
      wget
    ];

    security.sudo.wheelNeedsPassword = false;

    users.users.marco = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      openssh.authorizedKeys.keys = inputs.self.users.marco.ssh.publicKeys;
    };
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

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
