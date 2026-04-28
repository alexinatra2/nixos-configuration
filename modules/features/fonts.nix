{ self, ... }:
{
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          besley
          nerd-fonts.jetbrains-mono
          open-sans
        ];
        fontconfig = {
          enable = true;
          defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
        };
      };
    };

  flake.modules.homeManager.fonts =
    { pkgs, lib, ... }:
    {
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
