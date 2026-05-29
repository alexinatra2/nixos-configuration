{ self, inputs, ... }:
{
  flake.nixosModules.yubikey =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.local.yubikey = {
        enable = lib.mkEnableOption "YubiKey support";

        pamAuth = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable YubiKey PAM authentication for login, sudo, tty login services.";
          };

          settings = {
            authfile = lib.mkOption {
              type = lib.types.path;
              default = "/etc/u2f-mappings";
              description = "System-wide U2F key mappings file.";
            };

            control = lib.mkOption {
              type = lib.types.enum [
                "required"
                "requisite"
                "sufficient"
                "optional"
              ];
              default = "sufficient";
              description = "PAM control flag for pam_u2f. sufficient = YubiKey OR password.";
            };

            cue = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Show 'touch YubiKey' prompt before waiting for device.";
            };
          };
        };
      };

      config = lib.mkIf config.local.yubikey.enable {
        services.pcscd.enable = true;

        services.gnome.gcr-ssh-agent.enable = false;

        programs.ssh.startAgent = true;

        environment.systemPackages = with pkgs; [
          yubikey-manager
          yubikey-personalization
          opensc
        ];

        security.pam.u2f = lib.mkIf config.local.yubikey.pamAuth.enable {
          enable = true;
          control = config.local.yubikey.pamAuth.settings.control;
          settings = {
            authfile = config.local.yubikey.pamAuth.settings.authfile;
            cue = config.local.yubikey.pamAuth.settings.cue;
          };
        };

        security.pam.services = lib.mkIf config.local.yubikey.pamAuth.enable {
          ly.u2fAuth = true;
          sudo.u2fAuth = true;
          login.u2fAuth = true;
        };
      };
    };
}
