{ nativeExtension, pkgs, ... }:
(nativeExtension "podman")
// {
  runtimeTools = [ pkgs.podman ];
}
