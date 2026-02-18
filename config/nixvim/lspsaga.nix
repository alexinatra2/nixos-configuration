{
  plugins.lspsaga = {
    enable = true;
    settings = {
      beacon = {
        enable = true;
      };
      ui = {
        border = "rounded";
      };
      diagnostic = {
        borderFollow = true;
        diagnosticOnlyCurrent = false;
        showCodeAction = true;
      };
      symbolInWinbar = {
        enable = true; # Breadcrumbs
      };
      codeAction = {
        extendGitSigns = false;
        showServerName = true;
        onlyInCursor = true;
        numShortcut = true;
        keys = {
          exec = "<CR>";
          quit = [
            "<Esc>"
            "q"
          ];
        };
      };
      outline = {
        autoClose = true;
        autoPreview = true;
        closeAfterJump = true;
        layout = "normal"; # normal or float
        winPosition = "right"; # left or right
        keys = {
          jump = "<CR>";
          quit = "q";
          toggleOrJump = "<CR>";
        };
      };
      finder = {
        toggleOrOpen = "<CR>";
      };
    };
  };
}
