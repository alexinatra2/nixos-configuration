{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:

let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.system};
in
{
  options.firefox = {
    enable = lib.mkEnableOption "Enable Firefox configuration through Home Manager";

    enabledExtensions = {
      default = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the default Firefox extensions (uBlock Origin, Vimium).";
      };

      react-development = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable React development extensions (React DevTools, Redux DevTools).";
      };
    };
  };

  config = lib.mkIf config.firefox.enable {
    programs.firefox = {
      enable = true;
      languagePacks = [
        "de"
        "en-GB"
      ];

      profiles.default = {
        id = 0;
        name = "Default";

        extensions =
          (lib.optionals config.firefox.enabledExtensions.default (
            with firefox-addons;
            [
              ublock-origin
              vimium
            ]
          ))
          ++ (lib.optionals config.firefox.enabledExtensions.react-development (
            with firefox-addons;
            [
              react-devtools
              reduxdevtools
            ]
          ));
      };
    };
  };
}
