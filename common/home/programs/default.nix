{ hyprland, ... }:
{
  imports = [ ] ++ (if hyprland then [
    ./hyprland
    ./waybar
  ] else [ ]);
}
