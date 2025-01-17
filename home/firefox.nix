{
  pkgs,
  config,
  ...
}:
let
  locked = value: {
    Value = value;
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
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      ExtensionSettings = {
        # blocks all addons except the ones specified below
        "*".installation_mode = "blocked";
        # ublock Origin
        "uBlock0@raymondhill.net" = {
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
      Preferences = {
        "browser.newtabpage.activity-stream.feeds.section.topstories" = locked false;
        "browser.newtabpage.activity-stream.feeds.snippets" = locked false;
        "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = locked false;
        "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = locked false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = locked false;
        "browser.newtabpage.activity-stream.section.highlights.includeVisited" = locked false;
        "browser.newtabpage.activity-stream.showSponsored" = locked false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = locked false;
        "browser.newtabpage.activity-stream.system.showSponsored" = locked false;
        "browser.translations.automaticallyPopup" = locked false;
        "extensions.pocket.enabled" = locked false;
      };
    };
  };
}
