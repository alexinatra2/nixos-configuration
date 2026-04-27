{ ... }:
{
  flake.darwinModules.systemSettings = {
    system.defaults = {
      dock = {
        autohide = false;
        show-recents = true;
        tilesize = 27;
        wvous-br-corner = 14;
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };

      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };

      CustomUserPreferences = {
        "com.apple.AppleMultitouchTrackpad" = {
          Clicking = true;
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = false;
          TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
        };

        "com.apple.WindowManager" = {
          AppWindowGroupingBehavior = 1;
          AutoHide = false;
          EnableTiledWindowMargins = false;
          EnableTilingByEdgeDrag = false;
          EnableTilingOptionAccelerator = false;
          EnableTopTilingByEdgeDrag = false;
          HideDesktop = true;
          StageManagerHideWidgets = false;
          StandardHideWidgets = false;
        };

        "com.apple.controlcenter" = {
          "NSStatusItem VisibleCC AudioVideoModule" = true;
          "NSStatusItem VisibleCC Battery" = true;
          "NSStatusItem VisibleCC Clock" = true;
          "NSStatusItem VisibleCC NowPlaying" = true;
          "NSStatusItem VisibleCC WiFi" = true;
        };

        "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
          Clicking = true;
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = false;
          TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
        };

        "com.apple.menuextra.clock" = {
          ShowAMPM = true;
          ShowDate = 0;
          ShowDayOfWeek = true;
        };
      };
    };
  };
}
