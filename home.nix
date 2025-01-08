{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ./nvf-configuration
    ./home
  ];

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
    stateVersion = "24.11";
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    kitty = {
      enable = true;
      settings = {
        cursor_trail = 2;
      };
    };

    starship.enable = true;
    fzf.enable = true;
    alacritty.enable = true;
    lazygit.enable = true;
    zoxide.enable = true;

    home-manager.enable = true;
  };
}
