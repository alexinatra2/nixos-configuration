{ inputs, ... }:
{
  flake = {
    nixosModules.stylix =
      {
        lib,
        pkgs,
        ...
      }:
      let
        themes = {
          gruvbox = {
            scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
            polarity = "dark";
          };

          nord = {
            scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
            polarity = "dark";
          };

          tokyo-night-dark = {
            scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
            polarity = "dark";
          };

          material = {
            scheme = "${pkgs.base16-schemes}/share/themes/material.yaml";
            polarity = "dark";
          };
        };

        defaultTheme = "gruvbox";
        activeTheme = themes.${defaultTheme};
        extraThemes = lib.filterAttrs (name: _: name != defaultTheme) themes;
        mkThemeSpecialisation = theme: {
          stylix.base16Scheme = lib.mkForce theme.scheme;
          stylix.polarity = lib.mkForce theme.polarity;
        };
      in
      {
        imports = [ inputs.stylix.nixosModules.stylix ];

        stylix = {
          enable = true;
          autoEnable = true;
          base16Scheme = activeTheme.scheme;
          polarity = activeTheme.polarity;
          targets.grub.enable = false;
        };

        specialisation = lib.mapAttrs (_: theme: {
          configuration = mkThemeSpecialisation theme;
        }) extraThemes;
      };

    modules.homeManager.stylix =
      {
        config,
        pkgs,
        ...
      }:
      {
        imports = [ inputs.stylix.homeModules.stylix ];

        gtk.gtk4.theme = config.gtk.theme;

        stylix = {
          enable = true;
          autoEnable = true;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
          polarity = "dark";
          targets.firefox.enable = false;
          targets.neovim.enable = false;
        };
      };
  };
}
