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

      sops.secrets."mail/thunderbird/woodservant/app-password" = { };

      programs.thunderbird = {
        enable = true;

        profiles.default = {
          isDefault = true;
          accountsOrder = [ "woodservant" ];
        };
      };

      accounts.email.accounts = {
        woodservant = {
          address = "alexander@woodservant.com";
          primary = true;
          realName = "Alexander Holzknecht";
          userName = "alexander@woodservant.com";

          # Keep mailbox credentials out of the Nix store.
          passwordCommand = "${pkgs.coreutils}/bin/cat ${
            config.sops.secrets."mail/thunderbird/woodservant/app-password".path
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
