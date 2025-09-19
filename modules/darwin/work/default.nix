{ ... }:
{
  homebrew = {
    enable = true;
    brews = [
      "helm"
      "k3d"
      "tilt"
      "k9s"
    ];
    casks = [
      "slack"
    ];
  };
}
