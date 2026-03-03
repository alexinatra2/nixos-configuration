{
  home.shellAliases = {
    lg = "lazygit";
    open = "xdg-open";
    cd = "z";
    v = "vi";
    DN = "> /dev/null";
    DE = "2> /dev/null";
    C = "tee >(xclip -selection clipboard)";
    # vim-temp is a custom script defined through the `lib.writeShellScript` utility
    # it enables reading the output of a command into a temporary file and displaying
    # it in vim to optionally be saved somewhere
    VT = "vim-temp";
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    starship.enable = true;
    btop.enable = true;

    fzf = {
      enable = true;
      enableBashIntegration = true;

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
    };
  };
}
