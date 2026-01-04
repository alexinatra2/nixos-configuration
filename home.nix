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
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      cargo
      discord
      eduvpn-client
      gcc
      jdk21
      jetbrains-mono
      jetbrains.rust-rover
      nixfmt-rfc-style
      nodejs
      ollama
      pnpm
      qgis
      ripgrep
      spotify
      unzip
      xclip
    ];
    stateVersion = "24.11";
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  shell = {
    enable = true;
    enableBash = true;
  };

  programs = {
    kitty = lib.mkForce {
      enable = true;
      settings = {
        cursor_trail = 2;
        background_opacity = "0.9";
      };
    };

    home-manager.enable = true;
  };
}
