{ nativeExtension, pkgs, ... }:
(nativeExtension "power-profile")
// {
  runtimeTools = [ pkgs.power-profiles-daemon ];
}
