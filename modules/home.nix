{
  pkgs,
  username,
  lib,
  ...
}:
{
  imports = [
    ../home
    ./generations.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = lib.mkDefault "/home/${username}";
    packages =
      with pkgs;
      [
        cargo
        gcc
        jdk21
        nerd-fonts.jetbrains-mono
        lazydocker
        lazysql
        nixfmt
        nodejs
        pnpm
        ripgrep
        spotify
        unzip
        xclip
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
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
    enableZsh = true;
  };

  firefox = {
    enable = lib.mkDefault true;
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

  plasmaOverrides.enable = true;

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      # cursor_trail = 2;
      background_opacity = "0.9";
    };
  };
}
