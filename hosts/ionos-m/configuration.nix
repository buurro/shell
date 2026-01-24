{pkgs, ...}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "ionos-m";

  environment.systemPackages = [pkgs.k3s];

  networking.firewall.allowedTCPPorts = [6443];

  services.k3s.enable = true;
  services.k3s.role = "server";

  systemd.services.argocd = {
    requires = ["k3s.service"];
    after = ["k3s.service"];
    serviceConfig = let
      argoscript = pkgs.writeShellScriptBin "argocd" ''
        set -e

        ${pkgs.k3s}/bin/k3s kubectl create namespace argocd
        ${pkgs.k3s}/bin/k3s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
      '';
    in {
      ExecStart = "${argoscript}/bin/argocd";
    };
  };

  modules.home-manager.enable = true;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.stateVersion = "24.05";
}
