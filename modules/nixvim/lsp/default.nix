{
  lib,
  ...
}:
{
  imports = [
    ./servers.nix
  ];

  plugins.lsp = {
    enable = true;
    inlayHints = true;
  };

  plugins.lsp-format.enable = true;
  plugins.lspsaga = {
    enable = true;
    settings = {
      beacon = {
        enable = true;
      };
      ui = {
        border = "rounded"; # One of none, single, double, rounded, solid, shadow
        codeAction = "💡"; # Can be any symbol you want 💡
      };
      hover = {
        openCmd = "!floorp"; # Choose your browser
        openLink = "gx";
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
      lightbulb = {
        enable = false;
        sign = false;
        virtualText = true;
      };
      implement = {
        enable = false;
      };
      rename = {
        autoSave = false;
        keys = {
          exec = "<CR>";
          quit = [
            "<C-k>"
            "<Esc>"
          ];
          select = "x";
        };
      };
      outline = {
        autoClose = true;
        autoPreview = true;
        closeAfterJump = true;
        layout = "normal"; # normal or float
        winPosition = "right"; # left or right
        keys = {
          jump = "e";
          quit = "q";
          toggleOrJump = "o";
        };
      };
      scrollPreview = {
        scrollDown = "<C-f>";
        scrollUp = "<C-b>";
      };
    };
  };

  lsp.keymaps = [
    {
      key = "gd";
      lspBufAction = "definition";
    }
    {
      key = "gD";
      lspBufAction = "references";
    }
    {
      key = "K";
      lspBufAction = "hover";
    }
    {
      key = "<leader>r";
      lspBufAction = "rename";
    }
    {
      key = "<A-CR>";
      lspBufAction = "code_action";
    }
    {
      action = lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=-1, float=true }) end";
      key = "<A-p>";
    }
    {
      action = lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=1, float=true }) end";
      key = "<A-n>";
    }
  ];
}
