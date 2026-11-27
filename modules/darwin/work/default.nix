{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    buildkit
    go
    terragrunt
  ];
  homebrew = {
    enable = true;
    brews = [
      "helm"
      "k3d"
      "tilt"
    ];
    casks = [
      "slack"
    ];
  };
}
