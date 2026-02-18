# Neovim treesitter (syntax highlighting) aspect
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim-treesitter =
    { pkgs, ... }:
    {
      programs.nixvim = {
        plugins.treesitter = {
          enable = true;
          indent.enable = true;

          ensure_installed = [
            "typescript"
            "tsx"
            "javascript"
            "lua"
            "json"
            "html"
            "css"
            "nix"
            "rust"
          ];
        };

        plugins.treesitter-textobjects.enable = true;
      };
    };
}
