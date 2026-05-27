{ self, inputs, ... }:
{
  flake = {
    wrappers.firefox =
      {
        wlib,
        pkgs,
        ...
      }:
      {
        imports = [ wlib.modules.default ];

        config = {
          package = pkgs.firefox;
          filesToPatch = [ "share/applications/*.desktop" ];
        };
      };

    modules.homeManager.firefox =
      {
        lib,
        config,
        pkgs,
        ...
      }:
      let
        firefoxAddons = inputs.firefox-addons.packages.x86_64-linux;

        availableSearchEngines = {
          duckduckgo = {
            id = "ddg";
            urls = [ { template = "https://duckduckgo.com/?q={searchTerms}"; } ];
            icon = "https://duckduckgo.com/favicon.ico";
            definedAliases = [ "@d" ];
          };

          google = {
            id = "Google";
            urls = [ { template = "https://www.google.com/search?q={searchTerms}"; } ];
            icon = "https://www.google.com/favicon.ico";
            definedAliases = [ "@g" ];
          };

        };

        keywordShortcuts = [
          {
            key = "google-scholar";
            keyword = "scholar";
            url = "https://scholar.google.com/scholar?q=%s";
            guid = "ocffkwgoogle";
          }
          {
            key = "home-manager-options";
            keyword = "hm";
            url = "https://home-manager-options.extranix.com/?query=%s";
            guid = "ocffkwhmopts";
          }
          {
            key = "nixos-options";
            keyword = "nixos";
            url = "https://search.nixos.org/options?type=options&query=%s";
            guid = "ocffkwnixopt";
          }
          {
            key = "nixpkgs";
            keyword = "nixpkgs";
            url = "https://search.nixos.org/packages?channel=unstable&query=%s";
            guid = "ocffkwnixpkg";
          }
        ];

        enabledKeywordShortcuts = builtins.filter (
          shortcut: config.firefox.searchEngines.${shortcut.key} or false
        ) keywordShortcuts;

        managedKeywords = map (shortcut: shortcut.keyword) keywordShortcuts;

        sqlString = value: lib.replaceStrings [ "'" ] [ "''" ] value;

        managedKeywordsSql = lib.concatStringsSep ", " (
          map (keyword: "'${sqlString keyword}'") managedKeywords
        );

        shortcutSql = lib.concatMapStringsSep "\n" (shortcut: ''
          INSERT INTO moz_places (url, guid)
          SELECT '${sqlString shortcut.url}', '${sqlString shortcut.guid}'
          WHERE NOT EXISTS (
            SELECT 1 FROM moz_places WHERE url = '${sqlString shortcut.url}'
          );

          INSERT INTO moz_keywords (keyword, place_id, post_data)
          SELECT '${sqlString shortcut.keyword}', id, NULL
          FROM moz_places
          WHERE url = '${sqlString shortcut.url}'
          LIMIT 1;
        '') enabledKeywordShortcuts;
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
            home-manager-options = lib.mkEnableOption "Enable the @h Firefox keyword for Home Manager options.";
            google-scholar = lib.mkEnableOption "Enable the @s Firefox keyword for Google Scholar.";
            nixos-options = lib.mkEnableOption "Enable the @n Firefox keyword for NixOS options.";
            nixpkgs = lib.mkEnableOption "Enable the @x Firefox keyword for Nixpkgs.";
          };

          defaultSearchEngine = lib.mkOption {
            type = lib.types.enum (builtins.attrNames availableSearchEngines);
            default = "duckduckgo";
            description = "The default search engine to use in Firefox.";
          };
        };

        config = {
          firefox = {
            enable = lib.mkDefault true;
            enabledExtensions = {
              default = true;
              react-development = true;
            };
            defaultSearchEngine = "duckduckgo";
            searchEngines = {
              duckduckgo = true;
              google = true;
              google-scholar = true;
              home-manager-options = true;
              nixos-options = true;
              nixpkgs = true;
            };
          };
        }
        // lib.mkIf config.firefox.enable {
          programs.firefox = {
            enable = true;
            package = self.packages.x86_64-linux.firefox;
            policies.Certificates.ImportEnterpriseRoots = true;
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
                  with firefoxAddons;
                  [
                    ublock-origin
                    vimium
                  ]
                ))
                ++ (lib.optionals config.firefox.enabledExtensions.react-development (
                  with firefoxAddons;
                  [
                    react-devtools
                    reduxdevtools
                  ]
                ));

              search = {
                force = true;
                default = availableSearchEngines.${config.firefox.defaultSearchEngine}.id;
                engines = lib.filterAttrs (
                  id: _value: config.firefox.searchEngines.${id} or false
                ) availableSearchEngines;
              };
            };
          };

          home.activation.firefoxKeywordShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            firefoxPlacesDb="$HOME/.mozilla/firefox/default/places.sqlite"

            if [ ! -f "$firefoxPlacesDb" ]; then
              exit 0
            fi

            if ! ${lib.getExe pkgs.sqlite} "$firefoxPlacesDb" <<'SQL'
            .bail on
            .timeout 1000
            BEGIN IMMEDIATE;
            DELETE FROM moz_keywords WHERE keyword IN (${managedKeywordsSql});
            ${shortcutSql}
            COMMIT;
            SQL
            then
              echo "Skipping Firefox keyword shortcut update; close Firefox and run home-manager switch again." >&2
            fi
          '';
        };
      };
  };

}
