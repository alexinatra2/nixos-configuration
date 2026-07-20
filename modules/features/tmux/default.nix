{ self, inputs, ... }:
{
  flake.nixosModules.tmux =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      colors = config.lib.stylix.colors;
      accentColors = [
        colors.base08
        colors.base09
        colors.base0A
        colors.base0B
        colors.base0C
        colors.base0D
        colors.base0E
      ];
      colorCases = lib.imap0 (index: color: { inherit index color; }) (lib.init accentColors);
      windowColor = lib.foldr (
        case: fallback:
        "#{?#{==:#{e|m|:#{window_index},7},${toString case.index}},#${case.color},${fallback}}"
      ) "#${lib.last accentColors}" colorCases;
    in
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
          setw -g automatic-rename off
          setw -g allow-rename off

          set -g status-style 'fg=#${colors.base05},bg=#${colors.base00}'
          setw -g window-status-separator '''
          setw -g window-status-format '#[fg=#${colors.base00},bg=${windowColor},nobold] #I:#W#{?window_zoomed_flag,*Z,} #[fg=#${colors.base05},bg=#${colors.base00}]'
          setw -g window-status-current-format '#[fg=#${colors.base00},bg=${windowColor},bold] *#I:#W#{?window_zoomed_flag,*Z,} #[fg=#${colors.base05},bg=#${colors.base00},nobold]'

          bind g new-window -n lazygit -c '#{pane_current_path}' '${pkgs.lazygit}/bin/lazygit'
          bind r new-window -n serpl -c "#{pane_current_path}" "${pkgs.serpl}/bin/serpl"
          bind e new-window -n glow -c "#{pane_current_path}" "${pkgs.glow}/bin/glow"
          bind o new-window -n opencode -c "#{pane_current_path}" "${pkgs.opencode}/bin/opencode"

          bind c new-window -c '#{pane_current_path}'
          bind '"' split-window -v -c '#{pane_current_path}'
          bind % split-window -h -c '#{pane_current_path}'

          bind C command-prompt -p "New session:" \
            "new-session -d -c '#{pane_current_path}' -s '%%' \; \
             move-window -t '%%' \; \
             switch-client -t '%%'"

          bind x kill-pane
          bind X kill-window
        '';
      };
    };
}
