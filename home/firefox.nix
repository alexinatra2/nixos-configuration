{
  inputs,
  ...
}:
{
  programs.firefox = {
    enable = true;
    languagePacks = [
      "de"
      "en-GB"
    ];
    # profiles =
    #   let
    #     # bookmarks
    #     whatsappBM = {
    #       name = "WhatsApp";
    #       url = "https://web.whatsapp.com/";
    #     };
    #     chatgptBM = {
    #       name = "ChatGPT";
    #       url = "https://chatgpt.com/";
    #     };
    #     youtubeBM = {
    #       name = "Youtube";
    #       url = "https://www.youtube.com/";
    #     };
    #     githubBM = {
    #       name = "Github";
    #       url = "https://github.com/";
    #     };
    #     commerzbankBM = {
    #       name = "Commerzbank";
    #       url = "https://kunden.commerzbank.de/lp/login";
    #     };
    #   in
    #   {
    #     "personal" = {
    #       extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    #         profile-switcher
    #         react-devtools
    #         ublock-origin
    #       ];
    #       bookmarks = [
    #         whatsappBM
    #         chatgptBM
    #         youtubeBM
    #         commerzbankBM
    #         githubBM
    #       ];
    #     };
    #   };
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
      HttpsOnlyMode = "enabled";
      TranslateEnabled = false;
    };
  };
}
