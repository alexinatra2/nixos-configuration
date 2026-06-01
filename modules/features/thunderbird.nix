{ self, inputs, ... }:
{
  flake.modules.homeManager.thunderbird =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.homeManager.sops ];

      sops.secrets = {
        "thunderbird/woodservant/app-password" = { };
        "thunderbird/gmx/password" = { };
        "thunderbird/gmail/password" = { };
      };

      programs.thunderbird = {
        enable = true;

        profiles.default = {
          isDefault = true;
          accountsOrder = [
            "woodservant"
            "gmx"
            "gmail"
          ];
        };
      };

      accounts.email.accounts = {
        woodservant = {
          address = config.local.base.emailAddress;
          primary = true;
          realName = config.local.base.fullName;
          userName = config.local.base.emailAddress;

          # Keep mailbox credentials out of the Nix store.
          passwordCommand = "${pkgs.coreutils}/bin/cat ${
            config.sops.secrets."thunderbird/woodservant/app-password".path
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

        gmx = {
          address = "a.holzknecht@gmx.de";
          realName = config.local.base.fullName;
          userName = "a.holzknecht@gmx.de";

          # Keep mailbox credentials out of the Nix store.
          passwordCommand = "${pkgs.coreutils}/bin/cat ${
            config.sops.secrets."thunderbird/gmx/password".path
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

        gmail = {
          address = "alexander.holzknecht@gmail.com";
          realName = config.local.base.fullName;
          userName = "alexander.holzknecht@gmail.com";

          # Keep mailbox credentials out of the Nix store.
          passwordCommand = "${pkgs.coreutils}/bin/cat ${
            config.sops.secrets."thunderbird/gmail/password".path
          }";

          imap = {
            host = "imap.gmail.com";
            port = 993;
            tls.enable = true;
          };

          smtp = {
            host = "smtp.gmail.com";
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
