{ pkgs, ... }:
{
  extraPackages = with pkgs; [ lsof ];

  globals = {
    mapleader = " ";
    netrw_winsize = 20;
    netrw_liststyle = 3;
  };

  opts = {
    number = true;
    relativenumber = true;
    termguicolors = true;
    completeopt = [
      "menuone"
      "noselect"
      "noinsert"
    ];
    signcolumn = "yes";
    mouse = "a";
    ignorecase = true;
    smartcase = true;
    breakindent = true;
    cursorline = true;
    tabstop = 2;
    shiftwidth = 2;
    clipboard = "unnamedplus";
    encoding = "utf-8";
    fileencoding = "utf-8";
    undofile = true;
    swapfile = true;
    backup = false;
    autoread = true;
  };
}
