{ self, ... }:
{
  flake.nixosModules.fonts =
    { pkgs, lib, ... }:
    {
      fonts = {
        packages = with pkgs; [
          besley
          nerd-fonts.jetbrains-mono
          open-sans
        ];
        fontconfig = {
          enable = true;
          defaultFonts.monospace = lib.mkForce [
            "JetBrainsMono Nerd Font"
            "DejaVu Sans Mono"
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
          macos_option_as_alt = "yes";
        };
      };
    };
}
