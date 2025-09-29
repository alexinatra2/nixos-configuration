{
  pkgs,
  username,
  inputs,
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
      jetbrains.idea-ultimate
      jetbrains.rust-rover
      jetbrains.pycharm-professional
      jdk21
      nixfmt-rfc-style
      nodejs
      pnpm
      ripgrep
      spotify
      unzip
      xclip
      libreoffice-qt6-fresh
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
    kitty = {
      enable = true;
      settings = {
        cursor_trail = 2;
      };
    };

    home-manager.enable = true;
  };
}
