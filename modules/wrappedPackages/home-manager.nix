{ inputs, config, ... }:
{
  imports = [ inputs.hm-wrapper-modules.flakeModules.default ];

  hmWrappers = {
    home-manager = inputs.home-manager;
    stateVersion = "26.05";
    autoWrap = true;
    exclude = [
      "stylix"
      "firefox"
    ];
    baseModules = [ config.flake.modules.homeManager.stylix ];
  };
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      hmWrappers.programs = {
        tmux = {
          mainPackage = pkgs.tmux;
          homeModules = [ config.flake.modules.homeManager.tmux ];
        };

        neovim = {
          homeModules = [
            config.flake.modules.homeManager.neovim
          ];
        };

        git = {
          mainPackage = pkgs.git;
          homeModules = [ config.flake.modules.homeManager.git ];
        };

        opencode = {
          mainPackage = pkgs.opencode;
          homeModules = [ config.flake.modules.homeManager.opencode ];
        };

      };
    };
}
