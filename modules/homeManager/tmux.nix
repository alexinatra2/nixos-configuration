# Tmux configuration for Home Manager
{ ... }:
let
  tmuxPlugins =
    pkgs: with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
    ];

  tmuxPackages =
    pkgs:
    with pkgs;
    [
      xclip
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [ wl-clipboard ];
in
{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        clock24 = true;
        mouse = true;
        historyLimit = 10000;
        plugins = tmuxPlugins pkgs;
      };

      home.packages = tmuxPackages pkgs;
    };
}
