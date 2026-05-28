{ self, inputs, ... }:
{
  flake.nixosModules.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        baseIndex = 1;
        clock24 = true;
        customPaneNavigationAndResize = true;
        historyLimit = 10000;
        keyMode = "vi";
        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
          resurrect
          continuum
          tmux-sessionx
        ];
        extraConfig = ''
          set -g mouse on
          set -g status-keys vi
          set -s extended-keys on
          set -as terminal-features 'xterm*:extkeys'
          set -as terminal-features 'kitty:extkeys'
          setw -g pane-base-index 1
          set -g @sessionx-fzf-builtin-tmux 'on'
          set -g @sessionx-preview-location 'right'
          set -g @sessionx-preview-ratio '55%'
        '';
      };
    };

  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        baseIndex = 1;
        clock24 = true;
        customPaneNavigationAndResize = true;
        keyMode = "vi";
        mouse = true;
        historyLimit = 10000;
        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
          resurrect
          continuum
        ];
        extraConfig = ''
          set -g status-keys vi
          set -s extended-keys on
          set -as terminal-features 'xterm*:extkeys'
          set -as terminal-features 'kitty:extkeys'
          setw -g pane-base-index 1
        '';
      };

      home.packages = with pkgs; [
        xclip
      ];
    };
}
