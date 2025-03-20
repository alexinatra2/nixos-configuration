{
  pkgs,
  username,
  inputs,
  ...
}:
let
  ciJobToken = builtins.getEnv "CI_JOB_TOKEN";
in
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
      gradle
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

    file = {
      ".grade/grade.properties".text = ''
        inhouse3m5GitLabPrivateToken=${ciJobToken}
      '';
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  shell = {
    enable = true;
    enableBash = true;
  };

  programs.home-manager.enable = true;
}
