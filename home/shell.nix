{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.shell;
  shellAliases = {
    ls = "eza";
    cat = "bat";
    lg = "lazygit";
    open = "xdg-open";
    cd = "z";
  };
in
{
  options.shell = {
    enable = mkEnableOption "Shell overrides";
    enableBash = mkEnableOption "Bash overrides";
    enableNu = mkEnableOption "Nushell overrides";
  };

  config = mkIf cfg.enable {
    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        inherit shellAliases;
        initExtra = ''
          # tat: tmux attach
          function tat {
            name=$(basename `pwd` | sed -e 's/\.//g')

            if tmux ls 2>&1 | grep "$name"; then
              tmux attach -t "$name"
            elif [ -f .envrc ]; then
              direnv exec / tmux new-session -s "$name"
            else
              tmux new-session -s "$name"
            fi
          }
        '';
      };

      nushell = mkIf cfg.enableNu {
        enable = true;
        inherit shellAliases;
      };

      atuin = {
        enable = true;
        enableBashIntegration = mkIf cfg.enableBash true;
        flags = [ "--disable-up-arrow" ];
      };

      direnv = {
        enable = true;
        enableBashIntegration = mkIf cfg.enableBash true;
        nix-direnv.enable = true;
      };

      starship.enable = true;
      fzf.enable = true;
      zoxide.enable = true;

      bat.enable = true;
      eza.enable = true;

      carapace = {
        enable = true;
        enableNushellIntegration = mkIf cfg.enableNu true;
      };
    };
  };
}
