{
  pkgs,
  lib,
  ...
}:
{
  programs.tmux = {
    enable = true;

    # General behavior
    clock24 = true;
    mouse = true;
    historyLimit = 10000;

    # Plugins for sane defaults, clipboard, and session management
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
    ];
  };

  home.packages =
    with pkgs;
    [
      xclip
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      wl-clipboard
    ];
}
