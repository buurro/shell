{ config, inputs, pkgs, ... }: {
  imports = [
    ./disk-config.nix
    ./hardware-config.nix
  ];

  networking.hostName = "github-runner";

  age.secrets = {
    "github-runner-ncc-1" = {
      file = ../../secrets/github-runner-ncc-1.age;
      owner = "github-runner";
    };
  };
  users.users.github-runner = {
    isNormalUser = true;
  };

  services.github-runners =
    let
      package = pkgs.github-runner.overrideAttrs (oldAttrs: {
        patches = oldAttrs.patches ++ [
          (pkgs.fetchpatch {
            name = "self-pid.patch";
            url = "https://patch-diff.githubusercontent.com/raw/actions/runner/pull/2720.patch";
            hash = "sha256-swI0pMHo+uiaRSfp5OkhIIk6xWjxcoZ2nsoVELT6egQ=";
          })
        ];
      });
    in
    {
      ncc-1 = {
        inherit package;
        enable = true;
        user = "github-runner";
        name = "ncc-1";
        tokenFile = config.age.secrets."github-runner-ncc-1".path;
        url = "https://github.com/buurro/prenotazioni-ncc";
        extraPackages = with pkgs; [
          openssh
          curlFull
          jq
          docker
        ];
      };
    };

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [
    "github-runner"
    "marco"
  ];
  virtualisation.docker.autoPrune = {
    enable = true;
    dates = "monthly";
    flags = [
      "--all"
    ];
  };

  nix.gc = {
    automatic = true;
    options = "--delete-old";
    dates = "monthly";
  };

  system.stateVersion = "25.05";
}
