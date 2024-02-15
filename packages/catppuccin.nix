{ pkgs, variant, ... }: {
  grub = pkgs.stdenv.mkDerivation {
    name = "catppuccin-grub";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "grub";
      rev = "803c5df0e83aba61668777bb96d90ab8f6847106";
      hash = "sha256-/bSolCta8GCZ4lP0u5NVqYQ9Y3ZooYCNdTwORNvR7M0=";
    };
    installPhase = ''
      mkdir -p $out
      cp -R ./src/catppuccin-${variant}-grub-theme/* $out/
    '';
  };

  sddm = pkgs.stdenv.mkDerivation {
    name = "catppuccin-sddm";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "sddm";
      rev = "f3db13cbe8e99a4ee7379a4e766bc8a4c2c6c3dd";
      hash = "sha256-0zoJOTFjQq3gm5i3xCRbyk781kB7BqcWWNrrIkWf2Xk=";
    };
    installPhase = ''
      mkdir -p $out
      cp -R ./src/catppuccin-${variant}/* $out/
    '';
  };
}
