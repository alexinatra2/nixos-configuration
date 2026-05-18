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
    { pkgs, ... }:
    {
      environment.shellAliases = shellAliases;

      environment.systemPackages = with pkgs; [
        bat
        fd
        fzf
        kitty.terminfo
        starship
        tree
        xclip
        zoxide
      ];

      programs = {
        bash = {
          completion.enable = true;
          interactiveShellInit = ''
            eval "$(starship init bash)"
            eval "$(zoxide init bash)"
            source ${pkgs.fzf}/share/fzf/key-bindings.bash
            source ${pkgs.fzf}/share/fzf/completion.bash
          '';
          shellAliases = shellAliases;
        };

        fzf = {
          fuzzyCompletion = true;
          keybindings = true;
        };

        starship.enable = true;

        zoxide.enable = true;

        zsh = {
          autosuggestions.enable = true;
          enable = true;
          enableCompletion = true;
          interactiveShellInit = ''
            ${zshInit}
            eval "$(starship init zsh)"
            eval "$(zoxide init zsh)"
            source ${pkgs.fzf}/share/fzf/key-bindings.zsh
            source ${pkgs.fzf}/share/fzf/completion.zsh
          '';
          shellAliases = shellAliases;
          syntaxHighlighting.enable = true;
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
      home.shellAliases = shellAliases // {
        open = if pkgs.stdenv.isDarwin then "open" else shellAliases.open;
        C = if pkgs.stdenv.isDarwin then "tee >(pbcopy)" else shellAliases.C;
      };

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
