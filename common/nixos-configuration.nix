{ pkgs, lib, inputs, ... }:
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
    "${inputs.self}/modules/network-stuff.nix"
    "${inputs.self}/modules/hyprland/default.nix"
    "${inputs.self}/modules/kde.nix"
    "${inputs.self}/modules/nixos-home-manager.nix"
    "${inputs.self}/modules/authelia/default.nix"
  ];

  options = { };

  config = {
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
      openssh.authorizedKeys.keys = inputs.self.users.marco.ssh.publicKeys;
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

    programs.nix-ld.enable = lib.mkDefault true; # fixes vscode server and other stuff

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

    system.autoUpgrade = {
      enable = true;
      flake = "github:buurro/shell";
      dates = "02:00";
      randomizedDelaySec = "45min";
    };

    nixpkgs.config.allowUnfree = true;
  };
}
