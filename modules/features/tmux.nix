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
        ];
        extraConfig = ''
          is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+/)?g?(view|l?n?vim?x?)(diff)?$'"

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

          bind -n M-h if-shell "$is_vim" 'send-keys M-h' 'select-pane -L'
          bind -n M-j if-shell "$is_vim" 'send-keys M-j' 'select-pane -D'
          bind -n M-k if-shell "$is_vim" 'send-keys M-k' 'select-pane -U'
          bind -n M-l if-shell "$is_vim" 'send-keys M-l' 'select-pane -R'

          bind g new-window -n lazygit -c '#{pane_current_path}' '${pkgs.lazygit}/bin/lazygit'
          bind r new-window -n serpl -c "#{pane_current_path}" "${pkgs.serpl}/bin/serpl"
          bind o command-prompt -p "open app: " "new-window '%%'" 

          bind c new-window -c '#{pane_current_path}'
          bind '"' split-window -v -c '#{pane_current_path}'
          bind % split-window -h -c '#{pane_current_path}'

          bind x kill-pane
          bind X kill-window
        '';
      };
    };
}
