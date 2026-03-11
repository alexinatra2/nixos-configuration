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
in
{
  options.neovim = {
    enable = mkEnableOption "Neovim configuration";

    nixvim = mkEnableOption "Enable configuration using Nixvim";
  };

  imports = [ ./../modules/nixvim ];

  config = mkIf cfg.enable {
    programs.nixvim.enable = cfg.nixvim;

    programs.neovim.enable = !cfg.nixvim;
  };
}
