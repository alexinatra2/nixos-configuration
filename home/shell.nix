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
        sessionVariables = {
          NH_FLAKE = "/home/alexander/nixos-configuration";
          NH_OS_FLAKE = "/home/alexander/nixos-configuration";
        };
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

      fzf = {
        enable = true;
        enableBashIntegration = true;

        defaultOptions = [
          "--height=40%"
          "--layout=reverse"
          "--border"
          "--ansi"
          "--tiebreak=begin,length,index"
        ];

        defaultCommand = "fd --type f --hidden --follow --exclude .git";
      };
      fd.enable = true;

      zoxide = {
        enable = true;
        enableBashIntegration = true;
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
        enableBashIntegration = true;
      };

      carapace = {
        enable = true;
        enableNushellIntegration = mkIf cfg.enableNu true;
      };
    };
  };
}
