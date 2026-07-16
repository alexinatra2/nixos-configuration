{ self, inputs, ... }:
let
  zshInit = ''
    bindkey -e
    bindkey '^[^?' backward-kill-word
    bindkey '^[^H' backward-kill-word
    bindkey -M viins '^[^?' backward-kill-word
    bindkey -M viins '^[^H' backward-kill-word
  '';
in
{
  flake.nixosModules.shell =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.local.shell;
      isDefaultOrMaximal = cfg.toolset != "minimal";
      isMaximal = cfg.toolset == "maximal";
      shellAliasesIfEnabled = lib.mkIf isDefaultOrMaximal shellAliases;
      carapaceInit = shell: ''
        source <(${pkgs.carapace}/bin/carapace _carapace ${shell})
      '';

      shellAliases = {
        lg = "${lib.getExe pkgs.lazygit}";
        open = "${lib.getExe pkgs.handlr} open";
        o = "${lib.getExe pkgs.opencode}";
        s = "${lib.getExe pkgs.sysz}";
        cd = "z";
        t = "${lib.getExe pkgs.tmux} attach";
        tn = "${lib.getExe pkgs.tmux} new-session";
        v = if cfg.editorPackage != null then lib.getExe cfg.editorPackage else "${lib.getExe pkgs.vim}";
        DN = "> /dev/null";
        DE = "2> /dev/null";
        C = "${pkgs.coreutils}/bin/tee >(${lib.getExe pkgs.xclip} -selection clipboard)";
        ldo = "${lib.getExe pkgs.lazydocker}";
      };

      minimalPackages = with pkgs; [
        git
        tmux
      ];

      defaultPackages = with pkgs; [
        btop
        carapace
        fzf
        handlr
        lazygit
        lsd
        starship
      ];

      defaultExtraPackages = with pkgs; [
        kitty.terminfo
        xclip
      ];

      maximalPackages = with pkgs; [
        bat
        fd
        ripgrep
        uutils-coreutils-noprefix
        lazydocker
        sysz
      ];

      defaultEnvironmentVariables = {
        BAT_STYLE = "plain";
        FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
          "--height=70%"
          "--layout=reverse"
          "--border"
          "--ansi"
          "--tiebreak=length,end,begin"
        ];
        FZF_CTRL_T_COMMAND = "fd --type f";
        FZF_CTRL_T_OPTS = "--preview 'bat {}'";
        FZF_ALT_C_COMMAND = "fd --type d";
        FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200'";
      };

      editorEnvironmentVariables = {
        EDITOR = lib.getExe cfg.editorPackage;
        VISUAL = lib.getExe cfg.editorPackage;
      };

    in
    {
      imports = [ inputs.nix-index-database.nixosModules.default ];

      options.local.shell.toolset = lib.mkOption {
        type = lib.types.enum [
          "minimal"
          "default"
          "maximal"
        ];
        default = "default";
        description = "Host shell toolset tier.";
      };

      options.local.shell.editorPackage = lib.mkOption {
        type = with lib.types; nullOr package;
        default = null;
        description = "Package providing the default editor executable.";
      };

      config = {
        environment.shellAliases = shellAliasesIfEnabled;

        environment.variables = lib.mkMerge [
          (lib.mkIf isDefaultOrMaximal defaultEnvironmentVariables)
          (lib.mkIf (cfg.editorPackage != null) editorEnvironmentVariables)
        ];

        environment.systemPackages =
          minimalPackages
          ++ lib.optionals isDefaultOrMaximal (defaultPackages ++ defaultExtraPackages)
          ++ lib.optionals isMaximal maximalPackages;

        programs = {
          nix-index-database.comma.enable = true;

          direnv = {
            enable = isDefaultOrMaximal;
            enableBashIntegration = isDefaultOrMaximal;
            enableZshIntegration = isDefaultOrMaximal;
            nix-direnv.enable = isDefaultOrMaximal;
          };

          bash = {
            completion.enable = isDefaultOrMaximal;
            interactiveShellInit = lib.mkIf isDefaultOrMaximal (carapaceInit "bash");
            shellAliases = shellAliasesIfEnabled;
          };

          fzf = lib.mkIf isDefaultOrMaximal {
            fuzzyCompletion = true;
            keybindings = true;
          };

          starship.enable = isDefaultOrMaximal;

          zoxide.enable = isDefaultOrMaximal;

          zsh = {
            autosuggestions.enable = isDefaultOrMaximal;
            enable = true;
            enableCompletion = isDefaultOrMaximal;
            interactiveShellInit = lib.mkIf isDefaultOrMaximal ''
              ${zshInit}
              ${carapaceInit "zsh"}
            '';
            shellAliases = shellAliasesIfEnabled;
            syntaxHighlighting.enable = isDefaultOrMaximal;
          };
        };

      };
    };
}
