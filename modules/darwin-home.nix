{
  pkgs,
  username,
  lib,
  ...
}:
{
  home.homeDirectory = lib.mkForce "/Users/${username}";
  # Use Firefox with macOS-specific overrides (alternative to Homebrew)
  firefox.enable = true;

  home.packages = with pkgs; [
    gradle
    maven
  ];
}
