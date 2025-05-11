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
    ./nvf-configuration
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
      jetbrains.idea-ultimate
      jetbrains.rust-rover
      libreoffice-qt6-fresh
      nixfmt-rfc-style
      nodejs
      pnpm
      ripgrep
      slack
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
