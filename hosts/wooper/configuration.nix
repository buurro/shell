{ pkgs, ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "wooper";

  networking.firewall.allowedTCPPorts = [ 6443 ];

  environment.systemPackages = with pkgs; [
    k3s
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
  ];

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.k3s.enable = true;
  services.k3s.role = "server";

  systemd.services.argocd = {
    requires = [ "k3s.service" ];
    after = [ "k3s.service" ];
    serviceConfig =
      let
        argoscript = pkgs.writeShellScriptBin "argocd" ''
          set -e

          ${pkgs.k3s}/bin/k3s kubectl create namespace argocd
          ${pkgs.k3s}/bin/k3s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
        '';
      in
      {
        ExecStart = "${argoscript}/bin/argocd";
      };
  };


  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database DBuser auth-method
      local all all trust
      host all all 0.0.0.0/0 md5
      host all all ::/0 md5
    '';
  };

  nix.gc = {
    automatic = true;
    options = "--delete-old";
    dates = "monthly";
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.stateVersion = "25.05";
}
