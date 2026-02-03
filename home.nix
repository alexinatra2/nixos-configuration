{
  pkgs,
  username,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.stylix.homeModules.stylix
    ./home
    # ./modules/nvf
    ./modules/nixvim
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      cargo
      gcc
      jdk21
      jetbrains-mono
      nixfmt
      nodejs
      pnpm
      ripgrep
      spotify
      unzip
      xclip
      opencode
      lazydocker
      lazysql
    ];
    stateVersion = "24.11";
  };
  programs.home-manager.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  shell = {
    enable = true;
    enableBash = true;
  };

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      cursor_trail = 2;
      background_opacity = "0.9";
    };
  };

  programs.nh.enable = true;
}
