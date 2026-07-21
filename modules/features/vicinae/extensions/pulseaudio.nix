{ nativeExtension, pkgs, ... }:
(nativeExtension "pulseaudio")
// {
  runtimeTools = [ pkgs.pulseaudio ];
}
