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
    ../home
    ./generations.nix
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
    sessionVariables = {
      NH_FLAKE = "/home/${username}/nixos-configuration";
      NH_OS_FLAKE = "/home/${username}/nixos-configuration";
    };
  };
  programs.home-manager.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  shell = {
    enable = true;
    enableBash = true;
    enableZsh = true;
  };

  firefox = {
    enable = true;
    enabledExtensions = {
      default = true;
      react-development = true;
    };
    defaultSearchEngine = "duckduckgo";
    searchEngines = {
      duckduckgo = true;
      google = true;
      home-manager-options = true;
      nixos-options = true;
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

  neovim.enable = true;

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      cursor_trail = 2;
      background_opacity = "0.9";
    };
  };
}
