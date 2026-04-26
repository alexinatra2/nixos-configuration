{ inputs, ... }:
{
  flake.nixosModules.stylix =
    {
      lib,
      pkgs,
      ...
    }:
    let
      themes = {
        nord = {
          scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
          polarity = "dark";
        };

        gruvbox-dark-hard = {
          scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
          polarity = "dark";
        };
      };

      defaultTheme = "nord";
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
}
