{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.niri.homeModules.niri
    ./settings.nix
    ./keymaps.nix
  ];

  programs.niri.enable = true;

  home.packages = with pkgs; [
    xwayland-satellite
    wl-clipboard
  ];
}
