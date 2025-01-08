{
  pkgs,
  config,
  ...
}:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  mkAddonUrl = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
in
{
  programs.firefox = {
    enable = true;
    languagePacks = [
      "de"
      "en-GB"
    ];
    policies = {
      DisableFirefoxStudies = true;
      DisplayBookmarksToolbar = "always";
      DisablePocket = true;
      EnableTrackingProtection = {
        Cryptomining = true;
        Fingerprinting = true;
        Locked = true;
        Value = true;
      };
      TranslateEnabled = false;
      ExtensionSettings = {
        # blocks all addons except the ones specified below
        "*".installation_mode = "blocked";
        # ublock Origin
        "adblockultimate@adblockultimate.net" = {
          install_url = mkAddonUrl "ublock-origin";
          installation_mode = "force_installed";
        };
        # React Devtools
        "@react-devtools" = {
          install_url = mkAddonUrl "react-devtools";
          installation_mode = "force_installed";
        };
        # Detach Tab
        "claymont@mail.com_detach-tab" = {
          install_url = mkAddonUrl "detach-tab";
          installation_mode = "force_installed";
        };
      };
    };
  };
}
