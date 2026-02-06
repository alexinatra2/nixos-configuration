{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};

  availableSearchEngines = {
    duckduckgo = {
      name = "DuckDuckGo";
      urls = [ { template = "https://duckduckgo.com/?q={searchTerms}"; } ];
      icon = "https://duckduckgo.com/favicon.ico";
      definedAliases = [ "@d" ];
    };

    google = {
      name = "Google";
      urls = [ { template = "https://www.google.com/search?q={searchTerms}"; } ];
      icon = "https://www.google.com/favicon.ico";
      definedAliases = [ "@g" ];
    };

    home-manager-options = {
      name = "Home Manager Options";
      urls = [
        {
          template = "https://home-manager-options.extranix.com/?query={searchTerms}";
        }
      ];
      icon = "https://nixos.org/favicon.png";
      definedAliases = [ "@h" ];
    };

    nixos-options = {
      name = "NixOS Options";
      urls = [
        {
          template = "https://search.nixos.org/options";
          params = [
            {
              name = "type";
              value = "options";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "https://nixos.org/favicon.png";
      definedAliases = [ "@n" ];
    };
  };
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

    searchEngines = {
      duckduckgo = lib.mkEnableOption "Enable the DuckDuckGo search engine.";
      google = lib.mkEnableOption "Enable the Google search engine.";
      home-manager-options = lib.mkEnableOption "Enable search for Home Manager options.";
      nixos-options = lib.mkEnableOption "Enable search for NixOS options.";
    };

    defaultSearchEngine = lib.mkOption {
      type = lib.types.enum (builtins.attrNames availableSearchEngines);
      default = "duckduckgo";
      description = "The default search engine to use in Firefox.";
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
        path = "default";

        extensions.packages =
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

        search = {
          force = true;
          default = availableSearchEngines.${config.firefox.defaultSearchEngine}.name;
          engines = lib.filterAttrs (
            name: _value: config.firefox.searchEngines.${name} or false
          ) availableSearchEngines;
        };
      };
    };
  };
}
