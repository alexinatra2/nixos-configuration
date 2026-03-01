{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.shell;
in
{
  options.shell = {
    enable = mkEnableOption "Shell overrides";
    enableBash = mkEnableOption "Bash overrides";
    enableZsh = mkEnableOption "Zsh overrides";
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      lg = "lazygit";
      open = "xdg-open";
      cd = "z";
      v = "vi";
      DN = "> /dev/null";
      DE = "2> /dev/null";
      C = "tee >(xclip -selection clipboard)";
    };

    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
      };

      zsh = mkIf cfg.enableZsh {
        enable = true;
        enableCompletion = true;
        history = {
          # timestamp gets saved to history
          extended = true;
          # no duplicate history entries (upon re-submission of identical command new one overrides)
          ignoreAllDups = true;
          # share history across zsh sessions
          share = true;
          # amount of history lines to save
          save = 10000;
          # do not add commands to history that start with space
          ignoreSpace = true;
        };
        syntaxHighlighting.enable = true;
      };

      direnv = {
        enable = true;
        enableBashIntegration = mkIf cfg.enableBash true;
        enableZshIntegration = mkIf cfg.enableZsh true;
        nix-direnv.enable = true;
      };

      starship.enable = true;
      btop.enable = true;

      fzf = {
        enable = true;
        enableBashIntegration = mkIf cfg.enableBash true;
        enableZshIntegration = mkIf cfg.enableZsh true;

        defaultOptions = [
          "--height=70%"
          "--layout=reverse"
          "--border"
          "--ansi"
          "--tiebreak=length,end,begin"
        ];

        # input to fzf when using <C-t>
        fileWidgetCommand = "fd --type f";
        # options passed to fzf afterwards
        fileWidgetOptions = [
          "--preview 'bat {}'"
        ];

        # input to fzf when using <A-c>
        changeDirWidgetCommand = "fd --type d";
        # options passed to fzf afterwards
        changeDirWidgetOptions = [
          "--preview 'tree -C {} | head -200'"
        ];
      };

      zoxide = {
        enable = true;
        enableBashIntegration = mkIf cfg.enableBash true;
      };

      lazygit.enable = true;

      bat = {
        enable = true;
        config = {
          style = "plain";
        };
      };

      lsd = {
        enable = true;
        enableBashIntegration = mkIf cfg.enableBash true;
      };

      carapace = {
        enable = true;
      };
    };
  };
}
