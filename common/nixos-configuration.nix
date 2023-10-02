{ config, pkgs, lib, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    vim
    wget
    borgbackup
  ];

  security.sudo.wheelNeedsPassword = false;

  users.users.marco = {
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

  environment.shellAliases = {
    backups_keygen = "ssh-keygen -t ed25519 -C \"`hostname`-backups\" -f ~/.ssh/backups_ed25519";
  };

  time.timeZone = lib.mkDefault "Europe/Rome";

  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [ "root" "@wheel" ];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = lib.mkDefault "23.05";
}
