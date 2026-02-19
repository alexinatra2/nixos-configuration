{
  flake.modules.homeManager.shell =
    { config, lib, ... }:
    let
      commonShellAliases = {
        lg = "lazygit";
        open = "xdg-open";
        cd = "z";
        v = "vi";
        DN = "> /dev/null";
        DE = "2> /dev/null";
        C = "tee >(xclip -selection clipboard)";
      };

      fzfOptions = [
        "--height=50%"
        "--layout=reverse"
        "--border"
        "--ansi"
        "--tiebreak=begin,length,index"
        "--extended"
      ];
    in
    {
      options.shell = {
        enable = lib.mkEnableOption "Shell overrides" // {
          default = true;
        };
        enableBash = lib.mkEnableOption "Bash overrides" // {
          default = true;
        };
        enableZsh = lib.mkEnableOption "Zsh overrides" // {
          default = true;
        };
        enableFish = lib.mkEnableOption "Fish overrides" // {
          default = false;
        };
        enableNu = lib.mkEnableOption "Nushell overrides" // {
          default = false;
        };
      };

      config = lib.mkIf config.shell.enable {
        home.shellAliases = commonShellAliases;

        programs = {
          bash = {
            enable = true;
            enableCompletion = true;
          };

          fish = lib.mkIf config.shell.enableFish {
            enable = true;
          };

          zsh = lib.mkIf config.shell.enableZsh {
            enable = true;
            enableCompletion = true;
            history = {
              extended = true;
              ignoreAllDups = true;
              share = true;
              save = 10000;
              ignoreSpace = true;
            };
            syntaxHighlighting.enable = true;
            initContent = ''
              bindkey -M viins "^[^?" backward-kill-word
              bindkey -M vicmd "^[^?" backward-kill-word
            '';
          };

          nushell = lib.mkIf config.shell.enableNu {
            enable = true;
          };

          atuin = {
            enable = true;
            enableBashIntegration = lib.mkIf config.shell.enableBash true;
            enableZshIntegration = lib.mkIf config.shell.enableZsh true;
            flags = [ "--disable-up-arrow" ];
          };

          direnv = {
            enable = true;
            enableBashIntegration = lib.mkIf config.shell.enableBash true;
            enableZshIntegration = lib.mkIf config.shell.enableZsh true;
            nix-direnv.enable = true;
          };

          starship.enable = true;
          btop.enable = true;

          fzf = {
            enable = true;
            enableBashIntegration = lib.mkIf config.shell.enableBash true;
            enableZshIntegration = lib.mkIf config.shell.enableZsh true;
            enableFishIntegration = lib.mkIf config.shell.enableFish true;
            defaultOptions = fzfOptions;
          };

          zoxide = {
            enable = true;
            enableBashIntegration = lib.mkIf config.shell.enableBash true;
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
            enableBashIntegration = lib.mkIf config.shell.enableBash true;
          };

          carapace = {
            enable = true;
            enableNushellIntegration = lib.mkIf config.shell.enableNu true;
          };
        };
      };
    };
}
