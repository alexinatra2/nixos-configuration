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
      nvtopPackages.full
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

    home-manager.enable = true;
  };
}
