{
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = vim-tmux-navigator;
      }
    ];
    extraConfig = ''
      set -g base-index 1
      setw -g pane-base-index 1

      set -g renumber-windows on

      set -g mouse on

      # Use vim keybindings in copy mode
      setw -g mode-keys vi

      # Fix ESC delay in vim
      set -g escape-time 10

      unbind-key -T copy-mode-vi v

      bind-key -T copy-mode-vi v \
        send-keys -X begin-selection

      bind-key -T copy-mode-vi 'C-v' \
        send-keys -X rectangle-toggle

      bind-key -T copy-mode-vi y \
        send-keys -X copy-pipe-and-cancel "pbcopy"

      bind-key -T copy-mode-vi MouseDragEnd1Pane \
        send-keys -X copy-pipe-and-cancel "pbcopy"

      bind c new-window -c '#{pane_current_path}'

      bind j resize-pane -D 10
      bind k resize-pane -U 10
      bind l resize-pane -L 10
      bind h resize-pane -R 10
    '';
  };
}
