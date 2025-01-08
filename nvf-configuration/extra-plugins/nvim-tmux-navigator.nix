{ pkgs, inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      vimPlugins = prev.vimPlugins // {
        nvim-tmux-navigator = prev.vimUtils.buildVimPlugin {
          name = "nvim-tmux-navigator";
          src = inputs.nvim-tmux-navigator;
        };
      };
    })
  ];

  programs.nvf.settings.vim.extraPlugins."nvim-tmux-navigator" = {
    package = pkgs.vimPlugins.nvim-tmux-navigator;
    setup = "require('nvim-tmux-navigation').setup()";
  };
}
