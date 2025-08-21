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
    # icon picker from normal mode
    {
      key = "<M-i>";
      mode = "n";
      silent = true;
      action = ":IconPickerNormal<cr>";
      desc = "open icon picker";
    }
    # icon picker from insert mode
    {
      key = "<M-i>";
      mode = "i";
      silent = true;
      action = ":IconPickerInsert<cr>";
      desc = "open icon picker";
    }
    # open color picker
    {
      key = "<M-c>";
      mode = [
        "n"
        "i"
      ];
      silent = true;
      action = ":CccPick<cr>";
      desc = "open hex color picker";
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

    # JetBrains-like shortcuts
    # Duplicate line
    {
      key = "<C-d>";
      mode = "n";
      silent = true;
      action = "yyp";
      desc = "Duplicate line";
    }
    # Comment/uncomment line
    {
      key = "<C-/>";
      mode = [ "n" "v" ];
      silent = true;
      action = ":Commentary<cr>";
      desc = "Toggle comment";
    }
    # Go to declaration (similar to Ctrl+B in JetBrains)
    {
      key = "<C-b>";
      mode = "n";
      silent = true;
      action = ":lua vim.lsp.buf.definition()<cr>";
      desc = "Go to definition";
    }
    # Find usages (similar to Alt+F7 in JetBrains)
    {
      key = "<M-F7>";
      mode = "n";
      silent = true;
      action = ":lua vim.lsp.buf.references()<cr>";
      desc = "Find references";
    }
    # Refactor rename (similar to Shift+F6 in JetBrains)
    {
      key = "<S-F6>";
      mode = "n";
      silent = true;
      action = ":lua vim.lsp.buf.rename()<cr>";
      desc = "Rename symbol";
    }
    # Quick fix (similar to Alt+Enter in JetBrains)
    {
      key = "<M-cr>";
      mode = "n";
      silent = true;
      action = ":lua vim.lsp.buf.code_action()<cr>";
      desc = "Code action";
    }
    # Navigate to next error
    {
      key = "<F2>";
      mode = "n";
      silent = true;
      action = ":lua vim.diagnostic.goto_next()<cr>";
      desc = "Next diagnostic";
    }
    # Navigate to previous error
    {
      key = "<S-F2>";
      mode = "n";
      silent = true;
      action = ":lua vim.diagnostic.goto_prev()<cr>";
      desc = "Previous diagnostic";
    }
    # Show parameter hints (similar to Ctrl+P in JetBrains)
    {
      key = "<C-p>";
      mode = [ "i" "n" ];
      silent = true;
      action = ":lua vim.lsp.buf.signature_help()<cr>";
      desc = "Signature help";
    }
    # Organize imports
    {
      key = "<C-M-o>";
      mode = "n";
      silent = true;
      action = ":lua vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })<cr>";
      desc = "Organize imports";
    }
  ];
}
