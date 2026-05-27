{ self, inputs, ... }:
{
  flake.nixosModules.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        clock24 = true;
        historyLimit = 10000;
        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
          resurrect
          continuum
        ];
        extraConfig = ''
          set -g mouse on
        '';
      };
    };

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

      home.packages = with pkgs; [
        xclip
      ];
    };
}
