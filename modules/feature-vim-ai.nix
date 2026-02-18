# Neovim AI integration aspect (OpenCode)
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim-ai =
    { pkgs, ... }:
    {
      programs.nixvim = {
        plugins.snacks.enabled = true;

        plugins.opencode = {
          enable = true;
          settings = {
            input.enabled = true;
            auto_reload = true;
          };
        };

        keymaps = [
          {
            key = "<M-a>";
            action = "<CMD>lua require('opencode').toggle()<CR>";
            options = {
              desc = "Toggle OpenCode side panel";
              silent = true;
            };
          }
        ];
      };
    };
}
