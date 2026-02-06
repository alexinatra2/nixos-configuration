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
    ./modules/generations.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
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
      spotify
      unzip
      xclip
      wifitui
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

  firefox = {
    enable = true;
    enabledExtensions = {
      default = true;
      react-development = true;
    };
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
    provider = "nixvim";
  };

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      cursor_trail = 2;
      background_opacity = "0.9";
    };
  };
}
