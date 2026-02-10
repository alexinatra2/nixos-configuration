{
  pkgs,
  username,
  lib,
  ...
}:
{
  home.homeDirectory = lib.mkForce "/Users/${username}";
  home.packages = with pkgs; [
    gradle
    maven
  ];
}
