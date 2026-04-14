{ pkgs, ... }:
{
  services.skhd = {
    enable = true;
    config = ''
      # Launch Kitty from anywhere with Cmd+Enter.
      cmd - return : ${pkgs.kitty}/Applications/kitty.app/Contents/MacOS/kitty --single-instance -d ~
    '';
  };
}
