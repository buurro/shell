{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
  ];

  networking.hostName = "k8s-lab";

  networking.firewall.allowedTCPPorts = [80 443 6443];

  services.k3s.enable = true;
  services.k3s.role = "server";

  nix.gc = {
    automatic = true;
    options = "--delete-old";
  };

  system.stateVersion = "24.11";
}
