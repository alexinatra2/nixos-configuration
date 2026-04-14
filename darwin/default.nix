# nix-darwin configuration for MacBook
{
  pkgs,
  config,
  inputs,
  hostname,
  username,
  ...
}:
{
  imports = [
    ../modules/common.nix
    ./packages.nix
    ./system-settings.nix
  ];

  # Hostname configuration
  networking.hostName = hostname;

  system.primaryUser = username;

  # Homebrew integration (optional - requires Homebrew to be installed separately)
  homebrew = {
    enable = false;
    onActivation.cleanup = "zap";
  };

  # System version
  system.stateVersion = 5;
}
