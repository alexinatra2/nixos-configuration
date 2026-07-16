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

          bind g new-window -n lazygit -c '#{pane_current_path}' '${pkgs.lazygit}/bin/lazygit'
          bind r new-window -n serpl -c "#{pane_current_path}" "${pkgs.serpl}/bin/serpl"
          bind e new-window -n glow -c "#{pane_current_path}" "${pkgs.glow}/bin/glow"
          bind o new-window -n opencode -c "#{pane_current_path}" "${pkgs.opencode}/bin/opencode"

          bind c new-window -c '#{pane_current_path}'
          bind '"' split-window -v -c '#{pane_current_path}'
          bind % split-window -h -c '#{pane_current_path}'

          bind x kill-pane
          bind X kill-window
        '';
      };
    };
}
