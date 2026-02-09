# Shared configuration between NixOS and nix-darwin
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Nix configuration shared across systems
  nix = {
    enable = !pkgs.stdenv.isDarwin;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = !pkgs.stdenv.isDarwin;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Shared environment configuration
  environment = {
    # Common session variables / env vars
    variables = {
      EDITOR = "nvim";
      TERMINAL = "kitty";
    };

    # Common system packages
    systemPackages = with pkgs; [
      git
      vim
      wget
    ];
  };

  # Timezone - can be overridden per host
  time.timeZone = "Europe/Berlin";

  # Common program settings
  programs.zsh.enable = true;
}
