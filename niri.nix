{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.niri.homeManagerModules.niri
  ];
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    libsecret
  ];
  programs.niri = {
    enable = lib.mkForce true;
  };
}
