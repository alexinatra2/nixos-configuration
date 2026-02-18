# System state version configuration
{ ... }:
{
  flake.modules.nixos.stateVersion = {
    system.stateVersion = "24.05";
  };
}
