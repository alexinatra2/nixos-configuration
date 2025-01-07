{
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    extraConfig = ''
            set -g base-index 1
            setw -g pane-base-index 1

            set -g renumber-windows on

            # Use emacs keybindings in the status line
            set-option -g status-keys emacs

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
            bind '\' split-window -h -c '#{pane_current_path}'
            bind - split-window -v -c '#{pane_current_path}'

            set-option -g status-justify left
            set-option -g status-left-length 16
            set-option -g status-left '#[bg=colour72] #[bg=colour237] #[bg=colour236] #[bg=colour235]#[fg=colour185] #S #[bg=colour236] '
            set-option -g status-bg colour237
            set-option -g status-right '#[bg=colour236] #[bg=colour235]#[fg=colour185] %a %R #[bg=colour236]#[fg=colour3] #[bg=colour237] #[bg=colour72] #[]'
            set-option -g status-interval 60

            set-option -g pane-active-border-style fg=colour246
            set-option -g pane-border-style fg=colour238

            set-window-option -g window-status-format '#[bg=colour238]#[fg=colour107] #I #[bg=colour239]#[fg=colour110] #[bg=colour240]#W#[bg=colour239]#[fg=colour195]#F#[bg=colour238] '
            set-window-option -g window-status-current-format '#[bg=colour236]#[fg=colour215] #I #[bg=colour235]#[fg=colour167] #[bg=colour234]#W#[bg=colour235]#[fg=colour195]#F#[bg=colour236] '

      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator

      # decide whether we're in a Vim process
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'

      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -n 'C-Space' if-shell "$is_vim" 'send-keys C-Space' 'select-pane -t:.+'

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
      bind-key -T copy-mode-vi 'C-Space' select-pane -t:.+
    '';
  };

}
