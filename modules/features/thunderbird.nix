{ self, inputs, ... }:
{
  flake.modules.homeManager.thunderbird =
    {
      config,
      pkgs,
      ...
    }:
    {
      sops.secrets."mail/thunderbird/woodservant/password" = { };

      programs.thunderbird = {
        enable = true;

        profiles.default = {
          isDefault = true;
          accountsOrder = [ "woodservant" ];
        };
      };

      accounts.email.accounts = {
        "a.holzknecht@gmx.de" = {
          address = "a.holzknecht@gmx.de";
          realName = "Alexander Holzknecht";
          userName = "a.holzknecht@gmx.de";

          # Keep mailbox credentials out of the Nix store.
          passwordCommand = "${pkgs.coreutils}/bin/cat ${
            config.sops.secrets."mail/thunderbird/aholzknecht/password".path
          }";

          imap = {
            host = "imap.gmx.net";
            port = 993;
            tls.enable = true;
          };

          smtp = {
            host = "mail.gmx.net";
            port = 587;
            tls.enable = true;
          };

          thunderbird = {
            enable = true;
            profiles = [ "default" ];
          };
        };

        "alexander@woodservant.com" = {
          address = "alexander@woodservant.com";
          primary = true;
          realName = "Alexander Holzknecht";
          userName = "alexander@woodservant.com";

          # Keep mailbox credentials out of the Nix store.
          passwordCommand = "${pkgs.coreutils}/bin/cat ${
            config.sops.secrets."mail/thunderbird/woodservant/password".path
          }";

          imap = {
            host = "imap.purelymail.com";
            port = 993;
            tls.enable = true;
          };

          smtp = {
            host = "smtp.purelymail.com";
            port = 465;
            tls.enable = true;
          };

          thunderbird = {
            enable = true;
            profiles = [ "default" ];
          };
        };
      };
    };
}
