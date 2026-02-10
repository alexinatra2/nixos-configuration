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
    ../../modules/common.nix
    ../../modules/darwin/macos-packages.nix
  ];

  # Hostname configuration
  networking.hostName = hostname;

  system.primaryUser = username;

  # macOS system defaults
  system.defaults = {
    # Dock settings
    dock = {
      autohide = false;
      show-recents = true;
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

  # Homebrew integration (optional - requires Homebrew to be installed separately)
  homebrew = {
    enable = false;
    onActivation.cleanup = "zap";
  };

  # System version
  system.stateVersion = 5;
}
