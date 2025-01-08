{ ... }:
{
  programs.nvf.settings.vim.treesitter = {
    enable = true;
    mappings.incrementalSelection = {
      init = "<cr>";
      incrementByNode = "<cr>";
      incrementByScope = "<cr>";
      decrementByNode = "<bs>";
    };
  };
}
