{ config, pkgs, lib, ... }:
{
  networking.hostName = "qraspi";

  networking.firewall.allowedTCPPorts = [
    2049 # NFS
    9981 # TVHeadend
  ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
    kmod
  ];

  services.tvheadend.enable = true;

  fileSystems."/mnt/sandisk" = {
    device = "/dev/disk/by-uuid/e389b116-e8a1-481b-8b60-334ef44927a8";
    fsType = "ext4";
  };

  fileSystems."/export/sandisk" = {
    device = "/mnt/sandisk";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export blender.marco.ooo(rw,fsid=0,no_subtree_check)
    /export/sandisk blender.marco.ooo(rw,nohide,insecure,no_subtree_check)
  '';

  console.enable = false;

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4; # linuxPackages_latest is missing cxd2880 driver
    initrd.kernelModules = [ "cxd2880" "cxd2880-spi" ];
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*-rpi-4-*.dtb";
      kernelPackage = pkgs.linuxKernel.kernels.linux_rpi4;
      overlays = [
        {
          name = "spi1-2cs"; # using spi0-0cs did not work
          dtsText = ''
            /dts-v1/;
            /plugin/;


            / {
              compatible = "bcm2711";

              fragment@0 {
                target = <&gpio>;
                __overlay__ {
                  spi1_pins: spi1_pins {
                    brcm,pins = <19 20 21>;
                    brcm,function = <3>; /* alt4 */
                  };

                  spi1_cs_pins: spi1_cs_pins {
                    brcm,pins = <18 17>;
                    brcm,function = <1>; /* output */
                  };
                };
              };

              fragment@1 {
                target = <&spi1>;
                frag1: __overlay__ {
                  /* needed to avoid dtc warning */
                  #address-cells = <1>;
                  #size-cells = <0>;
                  pinctrl-names = "default";
                  pinctrl-0 = <&spi1_pins &spi1_cs_pins>;
                  cs-gpios = <&gpio 18 1>, <&gpio 17 1>;
                  status = "okay";

                  spidev1_0: spidev@0 {
                    compatible = "spidev";
                    reg = <0>;      /* CE0 */
                    #address-cells = <1>;
                    #size-cells = <0>;
                    spi-max-frequency = <125000000>;
                    status = "okay";
                  };

                  spidev1_1: spidev@1 {
                    compatible = "spidev";
                    reg = <1>;      /* CE1 */
                    #address-cells = <1>;
                    #size-cells = <0>;
                    spi-max-frequency = <125000000>;
                    status = "okay";
                  };
                };
              };

              fragment@2 {
                target = <&aux>;
                __overlay__ {
                  status = "okay";
                };
              };

              __overrides__ {
                cs0_pin  = <&spi1_cs_pins>,"brcm,pins:0",
                     <&frag1>,"cs-gpios:4";
                cs1_pin  = <&spi1_cs_pins>,"brcm,pins:4",
                     <&frag1>,"cs-gpios:16";
                cs0_spidev = <&spidev1_0>,"status";
                cs1_spidev = <&spidev1_1>,"status";
              };
            };
          '';
        }
        {
          name = "rpi-tv";
          dtsText = ''
            // rpi-tv HAT

            /dts-v1/;
            /plugin/;

            / {
              compatible = "bcm2711";

              fragment@0 {
                target = <&spidev0>;
                __overlay__ {
                  status = "disabled";
                };
              };

              fragment@1 {
                target = <&spi0>;
                __overlay__ {
                  /* needed to avoid dtc warning */
                  #address-cells = <1>;
                  #size-cells = <0>;

                  status = "okay";

                  cxd2880@0 {
                    compatible = "sony,cxd2880";
                    reg = <0>; /* CE0 */
                    spi-max-frequency = <50000000>;
                    status = "okay";
                  };
                };
              };

            };
          '';
        }
      ];
    };
  };

  # This causes an overlay which causes a lot of rebuilding
  environment.noXlibs = lib.mkForce false;
  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  system.stateVersion = "23.05";
}

