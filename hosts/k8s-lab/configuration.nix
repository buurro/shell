{ config, inputs, pkgs, ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
  ];

  networking.hostName = "k8s-lab";

  networking.firewall.allowedTCPPorts = [ 80 443 6443 ];

  services.k3s.enable = true;
  services.k3s.role = "server";

  system.stateVersion = "24.11";
}
