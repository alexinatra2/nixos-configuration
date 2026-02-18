# Platform-specific packages
{ ... }:
let
  defaultLinuxUsername = "alexander";
  # Linux desktop packages
  linuxDesktopPackages =
    pkgs: with pkgs; [
      alacritty
      firefox
      keepassxc
      vlc
      mpv
      desktop-file-utils
      android-tools
      home-manager
      cacert
    ];

  # macOS-specific packages
  darwinPackages =
    pkgs: with pkgs; [
      m-cli # macOS command line interface
    ];

  # Home Manager packages (common)
  homeCommonPackages =
    pkgs: with pkgs; [
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
    ];

  # Home Manager Linux-only packages
  homeLinuxPackages =
    pkgs: with pkgs; [
      wifitui
    ];
in
{
  flake.modules.nixos.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = linuxDesktopPackages pkgs;

      # Enable nh (NixOS helper)
      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          extraArgs = "--keep-since 4 --keep 3";
        };
        flake = "/home/${defaultLinuxUsername}/nixos-configuration";
      };

      # Enable email client
      programs.thunderbird.enable = true;
    };

  flake.modules.darwin.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = darwinPackages pkgs;
    };

  flake.modules.homeManager.packages =
    { pkgs, lib, ... }:
    {
      home.packages =
        homeCommonPackages pkgs ++ lib.optionals pkgs.stdenv.isLinux (homeLinuxPackages pkgs);

      # Enable nh for home-manager
      programs.nh = {
        enable = true;
        flake = "/home/${defaultLinuxUsername}/nixos-configuration";
        clean.enable = true;
      };
    };
}
