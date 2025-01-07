{ ... }:
{
  programs.nvf.settings.vim = {
    ui = {
      fastaction.enable = true;
      illuminate.enable = true;
      colorizer.enable = true;
      smartcolumn.enable = true;
    };
    visuals = {
      cinnamon-nvim.enable = true;
      highlight-undo.enable = true;
      indent-blankline.enable = true;
    };
  };
}
