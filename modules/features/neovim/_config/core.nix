{ pkgs, ... }:
{
  viAlias = true;
  vimAlias = true;
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

  userCommands.MergedLogs = {
    desc = "Open last 500 lines of Neovim logs in vertical terminal";
    command = ''
      :vertical terminal bash -c 'find $HOME/.local/state/nvim -type f -name "*.log" | xargs -I{} tail -n 500 "{}" | sort -r'
    '';
    nargs = 0;
    force = true;
  };
}
