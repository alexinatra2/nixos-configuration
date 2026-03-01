{
  viAlias = true;
  vimAlias = true;

  globals = {
    mapleader = " ";
    # commented out due to banner hiding causing high cpu usage for some reason
    # netrw_banner = 0;
    netrw_winsize = 20;
    # set netrw style to tree view
    netrw_liststyle = 3;
  };

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

    # Always show the signcolumn, otherwise text would be shifted when displaying error icons
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
}
