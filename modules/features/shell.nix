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

      maximalPackages = with pkgs; [
        bat
        fd
        ripgrep
        uutils-coreutils-noprefix
        lazydocker
        sysz
      ];

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
        environment.shellAliases = lib.mkIf isDefaultOrMaximal shellAliases;

        environment.variables = lib.mkMerge [
          (lib.mkIf isDefaultOrMaximal {
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
          })
          (lib.mkIf (cfg.editorPackage != null) {
            EDITOR = lib.getExe cfg.editorPackage;
            VISUAL = lib.getExe cfg.editorPackage;
          })
        ];

        environment.systemPackages =
          minimalPackages
          ++ lib.optionals isDefaultOrMaximal (
            defaultPackages
            ++ [
              pkgs.kitty.terminfo
              pkgs.xclip
            ]
          )
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
            interactiveShellInit = lib.mkIf isDefaultOrMaximal ''
              eval "$(starship init bash)"
              eval "$(zoxide init bash)"
              source <(${pkgs.carapace}/bin/carapace _carapace bash)
              source ${pkgs.fzf}/share/fzf/key-bindings.bash
              source ${pkgs.fzf}/share/fzf/completion.bash
            '';
            shellAliases = lib.mkIf isDefaultOrMaximal shellAliases;
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
              eval "$(starship init zsh)"
              eval "$(zoxide init zsh)"
              source <(${pkgs.carapace}/bin/carapace _carapace zsh)
              source ${pkgs.fzf}/share/fzf/key-bindings.zsh
              source ${pkgs.fzf}/share/fzf/completion.zsh
            '';
            shellAliases = lib.mkIf isDefaultOrMaximal shellAliases;
            syntaxHighlighting.enable = isDefaultOrMaximal;
          };
        };

      };
    };
}
