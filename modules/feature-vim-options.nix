# Neovim basic options aspect
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim-options =
    { pkgs, ... }:
    {
      programs.nixvim = {
        viAlias = true;
        vimAlias = true;

        globals.mapleader = " ";

        opts = {
          # Line numbers
          number = true;
          relativenumber = true;

          # Enable more colors (24-bit)
          termguicolors = true;

          # Have a better completion experience
          completeopt = [
            "menuone"
            "noselect"
            "noinsert"
          ];

          # Always show the signcolumn
          signcolumn = "yes";

          # Enable mouse
          mouse = "a";

          # Search
          ignorecase = true;
          smartcase = true;

          breakindent = true;
          cursorline = true;

          tabstop = 2;
          shiftwidth = 2;

          clipboard = "unnamedplus";

          # Set encoding
          encoding = "utf-8";
          fileencoding = "utf-8";

          # Save undo history
          undofile = true;
          swapfile = true;
          backup = false;
          autoread = true;
        };
      };
    };
}
