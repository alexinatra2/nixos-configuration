{
  flake.modules.darwin.darwin-system = {
    networking.hostName = "MacBook-Pro-von-Alexander";

    system.primaryUser = "alexanderholzknecht";

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

    # Homebrew integration
    homebrew = {
      enable = false;
      onActivation.cleanup = "zap";
    };

    # System version
    system.stateVersion = 5;
  };
}
