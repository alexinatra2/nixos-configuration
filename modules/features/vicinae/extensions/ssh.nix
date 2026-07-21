{ nativeExtension, pkgs, ... }:
(nativeExtension "ssh")
// {
  runtimeTools = [ pkgs.openssh ];
  settings."@leiserfg/vicinae-extension-ssh-0".preferences.terminal = pkgs.lib.getExe pkgs.kitty;
}
