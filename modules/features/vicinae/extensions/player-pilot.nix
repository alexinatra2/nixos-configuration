{ nativeExtension, pkgs, ... }:
(nativeExtension "player-pilot")
// {
  runtimeTools = [ pkgs.playerctl ];
}
