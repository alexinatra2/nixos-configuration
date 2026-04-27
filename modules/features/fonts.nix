{ self, ... }:
{
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
        fontconfig = {
          enable = true;
          defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
        };
      };
    };

  flake.modules.homeManager.fonts =
    { pkgs, lib, ... }:
    {
      home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

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
