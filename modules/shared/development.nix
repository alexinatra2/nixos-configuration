# Cross-platform development tools
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Development packages available on both platforms
  environment.systemPackages = with pkgs; [
    # Version control
    git

    # Text editors
    vim

    # File management and search
    ripgrep
    fd
    eza
    tree

    # Network tools
    curl
    wget

    # System monitoring
    htop
    btop

    # Compression
    zip
    unzip

    # Text processing
    jq
  ];
}
