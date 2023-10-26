{ config, pkgs, lib, inputs, ... }:
{
  networking.firewall.allowedTCPPorts = [
    5201 # iperf3
  ];

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    vim
    wget
    borgbackup
    iperf3
  ];

  security.sudo.wheelNeedsPassword = false;

  users.users.marco = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuIFl9HVJ5lRxADm5IBdEPimcFgmE3kMRfZ86g1slz9"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIR/Dqd+UXeEQovChEHgDhIIaXcrpa+i2/KwECTbkp5q marco@smart-blender"
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
