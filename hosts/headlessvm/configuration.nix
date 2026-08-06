# Same base as swayvm without the desktop: the console lands in the terminal
# you launched it from, so it works over ssh and inside a tmux pane. Handy for
# trying a change on linux before it goes near a real host.
{...}: {
  imports = [../../modules/nixos/vm.nix];

  networking.hostName = "headlessvm";

  virtualisation.vmVariant.virtualisation = {
    graphics = false; # -nographic: console on stdio, ctrl-a x to quit
    cores = 4;
    memorySize = 4096;
    diskSize = 8192;
    # ssh -p 2222 marco@localhost — minimal already installs marco's key
    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };
}
