{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      imports = [ ../../config/nixvim ];

      programs.nixvim = {
        enable = true;
        extraPackages = with pkgs; [ lsof ];
      };
    };
}
