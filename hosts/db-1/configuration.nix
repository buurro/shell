{ config, inputs, pkgs, ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
  ];

  networking.hostName = "db-1";
  networking.firewall.allowedTCPPorts = [ 5432 ];

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

  system.stateVersion = "25.05";
}
