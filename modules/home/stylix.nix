{ self, inputs, ... }:
{
  flake.modules.homeManager.stylix =
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
}
