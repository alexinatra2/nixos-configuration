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
    inputs.stylix.darwinModules.stylix
  ];

  # Hostname configuration
  networking.hostName = hostname;

  # User configuration
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # macOS system defaults
  system.defaults = {
    # Dock settings
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    # Trackpad settings
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };

    # Keyboard settings
    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };
  };

  # Enable nix-daemon
  services.nix-daemon.enable = true;

  # Additional macOS-specific packages
  environment.systemPackages = with pkgs; [
    firefox
    kitty
  ];

  # Homebrew integration (optional - requires Homebrew to be installed separately)
  homebrew = {
    enable = false;
    onActivation.cleanup = "zap";
  };

  # System version
  system.stateVersion = 5;
}
