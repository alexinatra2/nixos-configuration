{ lib, pkgs }:
let
  format = pkgs.formats.json { };
in
{
  inherit format;

  generate =
    {
      secretImports,
      userSettings,
    }:
    let
      settings = lib.recursiveUpdate {
        keybinding = "emacs";
        providers = {
          "@Gelei/vicinae-extension-bluetooth-0".preferences.connectionToggleable = true;
          "@jomifepe/bitwarden".preferences = {
            cliPath = lib.getExe pkgs.bitwarden-cli;
            fetchFavicons = false;
            repromptIgnoreDuration = "300000";
            serverCertsPath = "/etc/ssl/certs/ca-certificates.crt";
            shouldCacheVaultItems = true;
            syncOnLaunch = true;
            transientCopyGeneratePassword = "always";
            transientCopyGeneratePasswordQuick = "always";
            transientCopySearch = "always";
            windowActionOnCopy = "close";
          };
          "@leiserfg/vicinae-extension-ssh-0".preferences.terminal = lib.getExe pkgs.kitty;
          "@mrmartineau/search-npm".preferences.defaultCopyAction = "pnpm";
          "@samlinville/tailscale".preferences.tailscalePath = lib.getExe pkgs.tailscale;
        };
      } userSettings;
    in
    format.generate "vicinae-settings.json" (
      settings
      // {
        imports = (settings.imports or [ ]) ++ secretImports;
      }
    );
}
