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
      gcc
      jetbrains-mono
      jetbrains.rust-rover
      jdk21
      nixfmt-rfc-style
      nodejs
      pnpm
      ripgrep
      spotify
      unzip
      ollama
      xclip
      eduvpn-client
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

  programs.kitty = lib.mkDefault {
    enable = true;
    settings = {
      cursor_trail = 2;
      background_opacity = "0.9";
    };
  };

  programs.nh.enable = true;
}
