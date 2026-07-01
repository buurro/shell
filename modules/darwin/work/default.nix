{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    buildkit
    go
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
