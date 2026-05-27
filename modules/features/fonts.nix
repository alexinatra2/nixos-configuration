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

  flake.modules.homeManager.fonts =
    { pkgs, lib, ... }:
    {
      fonts.fontconfig = {
        enable = true;
        defaultFonts.monospace = lib.mkForce [
          "JetBrainsMono Nerd Font"
          "DejaVu Sans Mono"
        ];
      };

      home.packages = with pkgs; [
        besley
        nerd-fonts.jetbrains-mono
        open-sans
      ];

      programs.kitty = lib.mkForce {
        enable = true;
        settings = {
          font_family = "JetBrainsMono Nerd Font";
          background_opacity = "0.95";
        };
      };
    };
}
