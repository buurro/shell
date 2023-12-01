{ config, pkgs, lib, inputs, ... }:
let
  resize = pkgs.writeScriptBin "resize" ''
    if [ -e /dev/tty ]; then
      old=$(stty -g)
      stty raw -echo min 0 time 5
      printf '\033[18t' > /dev/tty
      IFS=';t' read -r _ rows cols _ < /dev/tty
      stty "$old"
      stty cols "$cols" rows "$rows"
    fi
  ''; # https://unix.stackexchange.com/questions/16578/resizable-serial-console-window
in
{
  imports = [
    "${inputs.self}/modules/backup.nix"
  ];

  networking.firewall.allowedTCPPorts = [
    5201 # iperf3
  ];

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    vim
    wget
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

  virtualisation.vmVariant = {
    virtualisation.graphics = false;
    virtualisation.qemu.options = [
      "-append 'console=ttyS0'"
      "-serial mon:stdio"
    ];
    virtualisation.diskSize = 8000;
    virtualisation.memorySize = 2048;
    environment.systemPackages = [ resize ];
    environment.loginShellInit = "${resize}/bin/resize";

    services.xserver.enable = false;
    services.xserver.displayManager.sddm.enable = false;
    services.xserver.desktopManager.plasma5.enable = false;

    users.users.marco.initialPassword = "marco";
    security.acme.defaults.server = "https://127.0.0.1";
    security.acme.preliminarySelfsigned = true;
  };

  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [ "root" "@wheel" ];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = lib.mkDefault "23.05";
}
