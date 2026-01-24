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
    inputs.catppuccin.nixosModules.catppuccin
    ./minimal.nix
    ../network-stuff.nix
    ../desktop.nix
    ../home-manager.nix
    ../adguard-home.nix
  ];

  options = { };

  config = {
    networking.firewall.allowedTCPPorts = [
      5201 # iperf3
    ];

    environment.systemPackages = with pkgs; [
      iperf3
      traceroute
    ];

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
      services.displayManager.sddm.enable = false;

      users.users.marco.initialPassword = "marco";
      security.acme.defaults.server = "https://127.0.0.1";
      security.acme.preliminarySelfsigned = true;
    };

    nixpkgs.config.allowUnfree = true;
    nix.channel.enable = false;
  };
}
