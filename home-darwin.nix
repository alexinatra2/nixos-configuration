{
  pkgs,
  username,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./home-darwin
    ./modules/generations.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/Users/${username}";
    packages = with pkgs; [
      cargo
      gcc
      jdk21
      jetbrains-mono
      lazydocker
      lazysql
      nixfmt
      nodejs
      pnpm
      ripgrep
      unzip
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

  opencode = {
    enable = true;
    agents = {
      build.enable = true;
      explore.enable = true;
      plan.enable = true;
      chat.enable = true;
      creative.enable = true;
      web.enable = true;
    };
  };

  mcp.enable = true;

  neovim = {
    enable = true;
  };

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      cursor_trail = 2;
      background_opacity = "0.9";
      macos_option_as_alt = true;
      macos_hide_titlebar = true;
    };
  };
}