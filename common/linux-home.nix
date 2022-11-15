{ config, pkgs, userInfo, ... }:
{
  home.username = "marco";
  home.homeDirectory = "/home/marco";

  nix.package = pkgs.nix;
}
