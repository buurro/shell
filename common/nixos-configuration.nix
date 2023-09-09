{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    vim
    wget
  ];

  security.sudo.wheelNeedsPassword = false;

  programs.zsh.enable = true;

  users.users.marco = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuIFl9HVJ5lRxADm5IBdEPimcFgmE3kMRfZ86g1slz9"
    ];
  };
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  time.timeZone = "Europe/Rome";

  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [ "root" "@wheel" ];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = lib.mkDefault "23.05";
}
