{ self, ... }:
{
  flake.nixosModules.fonts =
    { pkgs, lib, ... }:
    {
      fonts = {
        packages = with pkgs; [
          besley
          nerd-fonts.jetbrains-mono
          noto-fonts
          noto-fonts-color-emoji
          open-sans
        ];
        fontconfig = {
          enable = true;
          defaultFonts.emoji = [ "Noto Color Emoji" ];
          defaultFonts.monospace = lib.mkForce [
            "JetBrainsMono Nerd Font"
            "DejaVu Sans Mono"
          ];
          defaultFonts.sansSerif = [
            "Open Sans"
            "DejaVu Sans"
            "Noto Color Emoji"
          ];
          defaultFonts.serif = [
            "Besley"
            "DejaVu Serif"
            "Noto Color Emoji"
          ];
        };
      };
    };

}
