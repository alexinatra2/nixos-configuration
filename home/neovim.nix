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
  };

  imports = [ ./../modules/nixvim ];

  config = mkIf cfg.enable {
    programs.nixvim.enable = true;
  };
}
