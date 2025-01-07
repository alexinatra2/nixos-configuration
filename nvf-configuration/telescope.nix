{ ... }:
{
  programs.nvf.settings.vim = {
    telescope = {
      enable = true;
      mappings = {
        # this is the default binding for findFiles
        # findFiles = "<leader>ff";
        liveGrep = "<leader>/";
      };
    };
  };
}
