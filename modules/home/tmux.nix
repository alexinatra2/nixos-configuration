{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        clock24 = true;
        mouse = true;
        historyLimit = 10000;
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
        ++ lib.optionals pkgs.stdenv.isLinux [ wl-clipboard ];
    };
}
