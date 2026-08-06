{
  inputs,
  pkgs,
  lib,
  ...
}: {
  networking.hostName = "swayvm";

  programs.sway.enable = true;
  hardware.graphics.enable = true;

  modules.home-manager.enable = true;
  home-manager.backupFileExtension = "bak";
  home-manager.users.marco = {
    imports = [../../modules/home-manager/sway/default.nix];
    # qemu's cocoa display maps guest pixels to macos points (no hidpi
    # backing), so fonts render double: halve the base config's 18
    programs.alacritty.settings.font.size = lib.mkForce 9;
  };

  fonts.packages = [pkgs.nerd-fonts.meslo-lg];

  # the minimal profile ships almost no terminfo; alacritty's own comes
  # with the package, this covers root shells and anything ssh'ing in
  environment.enableAllTerminfo = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.sway}/bin/sway";
      user = "marco";
    };
  };

  environment.sessionVariables = {
    # no 3d acceleration in the vm, let wlroots use llvmpipe
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  system.autoUpgrade.enable = false;

  # dummy boot/fs config so the non-vm system still evaluates
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.systemd-boot.enable = true;

  virtualisation.vmVariant = {
    virtualisation = {
      host.pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      # no gpu passthrough behind qemu's cocoa display, so everything is
      # drawn by llvmpipe on the cpu — it scales with cores, and the ram
      # keeps the 9p-mounted host store in page cache between launches
      cores = 8;
      memorySize = 8192;
      diskSize = 8192;
      qemu.options = [
        "-device virtio-gpu-pci"
        "-device virtio-tablet-pci"
        # cocoa only reports window size to the guest at boot, so start
        # fullscreen; zoom-to-fit scales the picture if windowed later.
        # full-grab captures cmd shortcuts so cmd works as sway's mod.
        # no show-cursor: it sets cursor_hide=0 in ui/cocoa.m, which turns
        # the [NSCursor hide] on grab into a no-op and leaves the macOS
        # pointer floating over sway's own cursor
        "-display cocoa,full-screen=on,zoom-to-fit=on,full-grab=on"
      ];
    };
    users.users.marco.initialPassword = "marco";
  };

  system.stateVersion = "25.11";
}
