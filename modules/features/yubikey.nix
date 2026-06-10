{ self, inputs, ... }:
{
  flake.nixosModules.yubikey =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      cfg = config.local.yubikey;
    in
    {
      options.local.yubikey = {
        enable = lib.mkEnableOption "YubiKey support";

        pamAuth = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable YubiKey PAM authentication.";
          };

          user = lib.mkOption {
            type = lib.types.str;
            default = "alexander";
            description = "Unix user for the pam-u2f mapping file.";
          };

          settings = {
            control = lib.mkOption {
              type = lib.types.enum [
                "required"
                "requisite"
                "sufficient"
                "optional"
              ];
              default = "sufficient";
              description = "sufficient = YubiKey OR password.";
            };

            cue = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Show touch YubiKey prompt.";
            };

            interactive = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable interactive pam-u2f prompts.";
            };
          };

          services = {
            ly = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable YubiKey PAM authentication for ly.";
            };

            sudo = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable YubiKey PAM authentication for sudo.";
            };

            login = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable YubiKey PAM authentication for console login.";
            };
          };
        };
      };

      config = lib.mkIf cfg.enable {
        services.pcscd.enable = true;

        services.gnome.gcr-ssh-agent.enable = false;
        programs.ssh.startAgent = true;

        hardware.gpgSmartcards.enable = true;

        environment.systemPackages = with pkgs; [
          yubikey-manager
          yubikey-personalization
          pam_u2f
          opensc
        ];

        sops.secrets."yubikey/credentials/main" = { };
        sops.secrets."yubikey/credentials/backup" = { };

        sops.templates."yubico-u2f-keys" = lib.mkIf cfg.pamAuth.enable {
          content = "${cfg.pamAuth.user}:${config.sops.placeholder."yubikey/credentials/main"}:${
            config.sops.placeholder."yubikey/credentials/backup"
          }\n";
          mode = "0400";
        };

        security.pam.u2f = lib.mkIf cfg.pamAuth.enable {
          enable = true;
          control = cfg.pamAuth.settings.control;
          settings = {
            authfile = config.sops.templates."yubico-u2f-keys".path;
            cue = cfg.pamAuth.settings.cue;
            interactive = cfg.pamAuth.settings.interactive;
          };
        };

        security.pam.services = lib.mkIf cfg.pamAuth.enable {
          ly.u2f.enable = cfg.pamAuth.services.ly;
          sudo.u2f.enable = cfg.pamAuth.services.sudo;
          login.u2f.enable = cfg.pamAuth.services.login;
        };
      };
    };
}
