{
  pkgs,
  raycastRevision,
  vicinaeLib,
  ...
}:
{
  installName = "bitwarden";
  package = vicinaeLib.mkRayCastExtension {
    name = "bitwarden";
    rev = raycastRevision;
    hash = "sha256-kSIfQcnAZuwT9ipXOJR3nMLlwS4OXX03mP5jX1ktwnw=";
  };
  runtimeTools = [ pkgs.bitwarden-cli ];
  settings."@jomifepe/bitwarden".preferences = {
    cliPath = pkgs.lib.getExe pkgs.bitwarden-cli;
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
}
