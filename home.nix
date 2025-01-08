{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      android-studio
      discord
      gcc
      jetbrains-toolbox
      lazydocker
      lazygit
      libreoffice-qt6-fresh
      nixfmt-rfc-style
      nodejs
      obsidian
      pnpm
      ripgrep
      slack
      synology-drive-client
      teams-for-linux
    ];
  };

  imports = [
    ./nvf-configuration
    ./home
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "alexinatra2";
    userEmail = "a.holzknecht@gmx.de";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
  };

  programs.alacritty = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          caffeine.extensionUuid
        ];
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      cursor_trail = 2;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mod, F, exec, firefox"
          ", Print, exec, grimblast copy area"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = i + 1;
              in
              [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            ) 9
          )
        );
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
