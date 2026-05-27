{ inputs, ... }:
{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.nixvim-config.packages.x86_64-linux.default
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
}
