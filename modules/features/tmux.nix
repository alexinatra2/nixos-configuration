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
          unbind C-b
          set -g prefix C-Space
          bind C-Space send-prefix
          set -g mouse on
          set -g renumber-windows on
          set -g status-keys vi
          set -s extended-keys always
          set -as terminal-features 'xterm*:extkeys'
          set -as terminal-features 'kitty:extkeys'
          setw -g pane-base-index 1
          bind c new-window -c '#{pane_current_path}'
          bind '"' split-window -v -c '#{pane_current_path}'
          bind % split-window -h -c '#{pane_current_path}'
          bind x kill-pane
          bind X kill-window
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
          unbind C-b
          set -g prefix C-Space
          bind C-Space send-prefix
          set -g renumber-windows on
          set -g status-keys vi
          set -s extended-keys always
          set -as terminal-features 'xterm*:extkeys'
          set -as terminal-features 'kitty:extkeys'
          setw -g pane-base-index 1
          bind c new-window -c '#{pane_current_path}'
          bind '"' split-window -v -c '#{pane_current_path}'
          bind % split-window -h -c '#{pane_current_path}'
          bind x kill-pane
          bind X kill-window
        '';
      };
    };
}
