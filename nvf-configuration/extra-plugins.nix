{ pkgs, ... }:
{
  programs.nvf.settings.vim.extraPlugins = with pkgs.vimPlugins; {
    aerial = {
      package = aerial-nvim;
      setup = ''
        require('aerial').setup {}
      '';
    };
    harpoon = {
      package = harpoon;
      setup = "require('harpoon').setup {}";
      after = [ "aerial" ];
    };
  };
}
