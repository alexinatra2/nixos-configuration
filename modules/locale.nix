# Locale and timezone configuration
{ ... }:
let
  timeZone = "Europe/Berlin";
in
{
  flake.modules.nixos.locale = {
    i18n = {
      defaultLocale = "en_GB.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };
    };
    time.timeZone = timeZone;
  };

  # Darwin uses macOS system settings for locale
  flake.modules.darwin.locale = {
    time.timeZone = timeZone;
  };
}
