{
  config.flake.modules.homeManager.vim-ui = {
    programs.nixvim = {
      # Enable web-devicons for UI icons
      plugins.web-devicons.enable = true;

      plugins.noice.enable = true;
    };
  };
}
