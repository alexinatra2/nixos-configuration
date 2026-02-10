{
  pkgs,
  lib,
  ...
}:
{
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    image = ../background.png;
    polarity = "dark";
    targets = lib.mkIf pkgs.stdenv.isLinux {
      firefox.enable = false;
    };
  };
}
