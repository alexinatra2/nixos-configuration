{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.shell;
  shellAliases = {
    lg = "lazygit";
    open = "xdg-open";
    cd = "z";
  };
  ciJobToken = builtins.getEnv "CI_JOB_TOKEN";
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
        profileExtra = ''
          export CI_JOB_TOKEN=${ciJobToken}
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
      btop.enable = true;
      fzf.enable = true;
      zoxide.enable = true;
      lazygit.enable = true;

      bat = {
        enable = true;
        config = {
          style = "plain";
        };
      };

      lsd = {
        enable = true;
        enableAliases = true;
      };

      carapace = {
        enable = true;
        enableNushellIntegration = mkIf cfg.enableNu true;
      };
    };
  };
}
