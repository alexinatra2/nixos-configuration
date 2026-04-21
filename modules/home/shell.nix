{ self, inputs, ... }:
{
  flake.modules.homeManager.shell =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home.shellAliases = {
        lg = "lazygit";
        open = if pkgs.stdenv.isDarwin then "open" else "xdg-open";
        cd = "z";
        v = "vi";
        DN = "> /dev/null";
        DE = "2> /dev/null";
        C = if pkgs.stdenv.isDarwin then "tee >(pbcopy)" else "tee >(xclip -selection clipboard)";
        VT = "vim-temp";
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
          initContent = ''
            bindkey -e
            bindkey '^[^?' backward-kill-word
            bindkey '^[^H' backward-kill-word
            bindkey -M viins '^[^?' backward-kill-word
            bindkey -M viins '^[^H' backward-kill-word
          '';
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
