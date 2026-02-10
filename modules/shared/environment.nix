# Cross-platform environment configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Common session variables / env vars
  environment.variables = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
  };

  # Basic system packages available on both platforms
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    ripgrep
    fd
    eza
  ];

  # Additional platform-specific packages can be added by extending this list
  # in the platform-specific configurations
}
