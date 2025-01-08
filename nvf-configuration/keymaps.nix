{ ... }:
{
  programs.nvf.settings.vim.keymaps = [
    # alt backspace to delete last word under cursor
    {
      key = "<M-bs>";
      mode = "i";
      silent = true;
      action = "<C-w>";
      desc = "delete current word";
    }
    # save with ctrl+s
    {
      key = "<C-s>";
      mode = [
        "n"
        "i"
        "x"
      ];
      silent = true;
      action = "<esc>:w<cr>";
      desc = "save buffer";
    }
    # jj as an alias for escape in insert mode
    {
      key = "jj";
      mode = "i";
      silent = true;
      action = "<esc>";
    }
    # improve Y behavior - yank line to end starting from cursor
    {
      key = "Y";
      mode = "x";
      silent = true;
      action = "y$";
    }
    # improve y behavior - yank and keep cursor at position
    {
      key = "y";
      mode = "x";
      silent = true;
      action = "may`a";
    }
    # substitute word under cursor (repeatable with .)
    {
      key = "<C-n>";
      mode = "n";
      silent = true;
      action = "*Ncgn";
    }
    # sort selection
    {
      key = "<leader>s";
      mode = [
        "v"
        "x"
      ];
      silent = true;
      action = ":sort<cr>";
      desc = "sort selection";
    }
    # swap lines
    {
      key = "<M-j>";
      mode = "n";
      silent = true;
      action = ":m .+1<CR>==";
      desc = "swap line down";
    }
    {
      key = "<M-k>";
      mode = "n";
      silent = true;
      action = ":m .-2<CR>==";
      desc = "swap line up";
    }
    {
      key = "<M-j>";
      mode = "v";
      silent = true;
      action = ":m '>+1<CR>gv=gv";
      desc = "swap selection with line below";
    }
    {
      key = "<M-k>";
      mode = "v";
      silent = true;
      action = ":m '>-2<CR>gv=gv";
      desc = "swap selection with line above";
    }

    # plugins
    # open Oil
    {
      key = "-";
      mode = "n";
      silent = true;
      action = ":Oil<cr>";
      desc = "Open Oil file explorer";
    }
  ];
}
