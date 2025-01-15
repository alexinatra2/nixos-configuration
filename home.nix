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
      cargo
      discord
      gcc
      jetbrains-toolbox
      lazydocker
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

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    image = ./background.png;
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

    atuin = {
      enable = false;
      enableBashIntegration = true;
    };

    nushell.enable = true;
    starship.enable = true;
    fzf.enable = true;
    alacritty.enable = true;
    lazygit.enable = true;
    zoxide.enable = true;

    home-manager.enable = true;
  };
}
