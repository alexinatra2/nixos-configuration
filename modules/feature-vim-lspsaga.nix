# Neovim LSP Saga (LSP UI enhancements) aspect
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim-lspsaga =
    { pkgs, ... }:
    {
      programs.nixvim = {
        # Enable web-devicons for LSP saga icons
        plugins.web-devicons.enable = true;

        plugins.lspsaga = {
          enable = true;
          settings = {
            beacon = {
              enable = true;
            };
            ui = {
              border = "rounded";
              kind = {
                # File type icons using nerd fonts
                File = "󰈙";
                Module = "󰆧";
                Namespace = "󰅪";
                Package = "󰏗";
                Class = "󰌗";
                Method = "󰆧";
                Property = "󰜢";
                Field = "󰜢";
                Constructor = "󰆧";
                Enum = "󰒻";
                Interface = "󰜰";
                Function = "󰊕";
                Variable = "󰀫";
                Constant = "󰏿";
                String = "󰀬";
                Number = "󰎠";
                Boolean = "󰨙";
                Array = "󰅪";
                Object = "󰅩";
                Key = "󰌋";
                Null = "󰟢";
                EnumMember = "󰒻";
                Struct = "󰙅";
                Event = "󰉒";
                Operator = "󰆕";
                TypeParameter = "󰊄";
              };
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
      };
    };
}
