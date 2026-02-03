{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.neovim;
  nvfPackage =
    (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [ ./../modules/nvf ];
    }).neovim;
in
{
  options.neovim = {
    enable = mkEnableOption "Neovim configuration";
    provider = mkOption {
      type = types.enum [
        "nixvim"
        "nvf"
      ];
      default = "nixvim";
      description = "Which Neovim configuration provider to use";
    };
  };

  imports = [ ./../modules/nixvim ];

  config = mkIf cfg.enable {
    programs.nixvim.enable = (cfg.provider == "nixvim");
    programs.neovim = mkIf (cfg.provider == "nvf") {
      enable = true;
      package = nvfPackage;
    };
  };
}
