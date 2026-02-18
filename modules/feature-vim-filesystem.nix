# Neovim filesystem (file explorer) aspect
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim-filesystem =
    { pkgs, ... }:
    {
      programs.nixvim = {
        plugins.neo-tree = {
          enable = true;
          settings = {
            filesystem = {
              follow_current_file = {
                enabled = true;
                leave_dirs_open = false;
              };
            };
          };
        };

        keymaps = [
          # neo-tree
          {
            key = "<M-e>";
            action = "<CMD>Neotree filesystem reveal toggle action=show<CR>";
            options = {
              desc = "Toggle Neotree [Neotree]";
              silent = true;
            };
          }
          {
            key = "<M-g>";
            action = "<CMD>Neotree source=git_status reveal toggle action=show<CR>";
            options = {
              desc = "Toggle Neotree (showing git files) [Neotree]";
              silent = true;
            };
          }
        ];
      };
    };
}
