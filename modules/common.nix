# Shared configuration between NixOS and nix-darwin
# This module combines all cross-platform shared configurations
{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:

{
  # Import all shared modules
  imports = [
    ./shared/nix-config.nix
    ./shared/environment.nix
    ./shared/development.nix
  ];

  # Pass special arguments to shared modules
  _module.args.username = username;
}
