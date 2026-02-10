# NixOS-specific packages and configurations
{
  pkgs,
  lib,
  username,
  ...
}:

{
  # NixOS-specific system packages (extends shared environment)
  environment.systemPackages = with pkgs; [
    # Desktop applications
    alacritty
    firefox
    keepassxc
    vlc
    mpv

    # System utilities
    desktop-file-utils
    android-tools
    home-manager

    # Security
    cacert
  ];

  # NixOS-specific environment variables
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
  };

  # Enable common shells (NixOS specific)
  programs = {
    zsh.enable = true;
    bash.enable = true;

    # Nix-ld for running non-Nix binaries
    nix-ld = {
      enable = true;
      libraries = [
        # add dynamic libraries here
      ];
    };

    # Steam gaming
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    # Game optimization
    gamemode.enable = true;

    # NixOS helper
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4 --keep 3";
      };
      flake = "/home/${username}/nixos-configuration";
    };

    # Email client
    thunderbird.enable = true;
  };

  # NixOS user configuration
  users = {
    # Default user shell
    defaultUserShell = pkgs.zsh;

    # Define NixOS user with additional groups
    users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # For sudo access
        "adbusers" # For Android development
        "docker" # For Docker access
        "networkmanager" # For network management
        "realtime" # For audio/real-time processes
        "audio" # For audio access
      ];
    };
  };
}
