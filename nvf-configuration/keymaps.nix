{ ... }:
{
  programs.nvf.settings.vim.keymaps = [
    # alt backspace to delete last word under cursor
    {
      key = "<M-bs>";
      mode = "i";
      silent = true;
      action = "<C-w>";
    }
    # save with ctrl+s
    {
      key = "<C-s>";
      mode = ["n" "i" "x"];
      silent = true;
      action = "<esc>:w<cr>";
    }
  ];
}
