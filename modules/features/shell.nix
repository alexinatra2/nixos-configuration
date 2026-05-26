{ self, inputs, ... }:
let
  shellAliases = {
    lg = "lazygit";
    open = "xdg-open";
    cd = "z";
    v = "vi";
    DN = "> /dev/null";
    DE = "2> /dev/null";
    C = "tee >(xclip -selection clipboard)";
    VT = "vim-temp";
  };

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

      minimalPackages = with pkgs; [
        git
        tmux
      ];

      defaultPackages = with pkgs; [
        fzf
        lazygit
        starship
      ];

      maximalPackages = with pkgs; [
        bat
        fd
        ripgrep
        uutils-coreutils-noprefix
      ];

      managedZshUsers =
        lib.mapAttrsToList
          (name: user: {
            inherit name;
            home = user.home;
          })
          (
            lib.filterAttrs (
              _: user: (user.isNormalUser or false) && user ? home && user.home != null
            ) config.users.users
          );
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

      config = {
        environment.shellAliases = lib.mkIf isDefaultOrMaximal shellAliases;

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

          bash = {
            completion.enable = isDefaultOrMaximal;
            interactiveShellInit = lib.mkIf isDefaultOrMaximal ''
              eval "$(starship init bash)"
              eval "$(zoxide init bash)"
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
            enable = isDefaultOrMaximal;
            enableCompletion = isDefaultOrMaximal;
            interactiveShellInit = lib.mkIf isDefaultOrMaximal ''
              ${zshInit}
              eval "$(starship init zsh)"
              eval "$(zoxide init zsh)"
              source ${pkgs.fzf}/share/fzf/key-bindings.zsh
              source ${pkgs.fzf}/share/fzf/completion.zsh
            '';
            shellAliases = lib.mkIf isDefaultOrMaximal shellAliases;
            syntaxHighlighting.enable = isDefaultOrMaximal;
          };
        };

        system.activationScripts.zshUserConfig = lib.mkIf isDefaultOrMaximal {
          text = lib.concatLines (
            [
              "# Prevent zsh-newuser-install from running for declarative users."
            ]
            ++ map (user: ''
              if [ -d ${lib.escapeShellArg user.home} ] && [ ! -e ${lib.escapeShellArg "${user.home}/.zshrc"} ]; then
                install -m 0644 -o ${lib.escapeShellArg user.name} -g users /dev/null ${lib.escapeShellArg "${user.home}/.zshrc"}
                printf '%s\n' '# Managed by NixOS: load the system zsh configuration.' 'source /etc/zshrc' > ${lib.escapeShellArg "${user.home}/.zshrc"}
              fi
            '') managedZshUsers
          );
        };
      };
    };

  flake.modules.homeManager.shell =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home.shellAliases = shellAliases;

      programs = {
        bash = {
          enable = true;
          enableCompletion = true;
        };

        zsh = {
          enable = true;
          dotDir = config.home.homeDirectory;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          initContent = zshInit;
          shellAliases = config.home.shellAliases;
        };

        direnv = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };

        starship.enable = true;
        btop.enable = true;

        fzf = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          defaultOptions = [
            "--height=70%"
            "--layout=reverse"
            "--border"
            "--ansi"
            "--tiebreak=length,end,begin"
          ];
          fileWidgetCommand = "fd --type f";
          fileWidgetOptions = [ "--preview 'bat {}'" ];
          changeDirWidgetCommand = "fd --type d";
          changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
        };

        zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        lazygit.enable = true;

        bat = {
          enable = true;
          config.style = "plain";
        };

        lsd = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        carapace.enable = true;
      };
    };
}
