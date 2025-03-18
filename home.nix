{
  pkgs,
  username,
  inputs,
  ...
}:
{
  imports = [
    inputs.nvf.homeManagerModules.default
    ./nvf-configuration
    ./home
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      cargo
      jetbrains-mono
      jetbrains.idea-ultimate
      maven
      nixfmt-rfc-style
      nodejs
      obsidian
      pnpm
      ripgrep
      spotify
      teams-for-linux
      yarn
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
    home-manager.enable = true;
  };
}
