{
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;

    # General behavior
    clock24 = true;
    mouse = true;
    historyLimit = 10000;
    terminal = "screen-256color";

    # Change prefix to Ctrl-Space
    prefix = "C-Space";

    # Plugins for sane defaults, clipboard, and session management
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
    ];

    extraConfig = ''
      # --- Prefix ---
      unbind C-b
      set-option -g prefix C-Space
      bind C-Space send-prefix

      # --- Clipboard Integration ---
      # Ensure tmux uses system clipboard (requires xclip or wl-clipboard)
      set-option -g set-clipboard on

      # Use the system clipboard explicitly when yanking (via tmux-yank plugin)
      if-shell "command -v xclip >/dev/null 2>&1" "set-option -g default-command 'reattach-to-user-namespace -l $SHELL'"
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -selection clipboard -in'

      # --- Pane Navigation (Vim-style with Ctrl-h/j/k/l) ---
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      # Optional: cycle through windows with Alt-h/l
      bind -n M-h previous-window
      bind -n M-l next-window

      # --- Seamless Neovim Integration ---
      # Allow Ctrl-h/j/k/l to move between nvim splits *and* tmux panes
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(n?vim|fzf|lf)$'"
      bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
      bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
      bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
      bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"

      # --- Visuals ---
      set -g status-bg colour236
      set -g status-fg white
      set -g status-left "#[fg=green]#H"
      set -g status-right "#[fg=yellow]%Y-%m-%d #[fg=cyan]%H:%M"
      set -g status-interval 5
      set -ga terminal-overrides ',xterm-256color:Tc'

      # --- Misc ---
      set-option -g base-index 1
      setw -g pane-base-index 1
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
      set -ga terminal-overrides ',xterm-kitty:Tc'
    '';
  };

  home.packages = with pkgs; [
    xclip
    wl-clipboard
  ];
}
