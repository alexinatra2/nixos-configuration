# Cross-platform user and shell configuration
{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  # User and shell configurations are now handled in platform-specific modules:
  # - NixOS: modules/linux/nixos-packages.nix
  # - Darwin: Uses system defaults (no configuration needed here)

  # This module is intentionally minimal since user management differs significantly
  # between NixOS (managed by nix-darwin) and Darwin (managed by macOS)
}
