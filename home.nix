{
  pkgs,
  username,
  inputs,
  ...
}:
{
  imports = [
    inputs.nvf.homeManagerModules.default
    inputs.stylix.homeManagerModules.stylix
    inputs.niri.homeModules.niri
    ./nvf-configuration
    ./home
    ./niri.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      cargo
      discord
      gcc
      jetbrains-mono
      jetbrains.idea-ultimate
      libreoffice-qt6-fresh
      nixfmt-rfc-style
      nodejs
      obsidian
      pnpm
      ripgrep
      slack
      spotify
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
    polarity = "dark";
    cursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 32;
    };
    targets = {
      firefox.enable = false;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  shell = {
    enable = true;
    enableBash = true;
  };

  programs = {
    kitty = {
      enable = true;
      settings = {
        cursor_trail = 2;
      };
    };

    firefox.enable = true;

    lazygit.enable = true;

    home-manager.enable = true;
  };
}
