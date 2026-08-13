{ self, inputs, ... }:
{
  flake = {
    nixosModules.base =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.local.base;

        passwordHashSecret = "users/${cfg.username}/password-hash";
        privateSshKeySecret = "users/${cfg.username}/private-ssh-key";

      in
      {
        options.local.base = {
          username = lib.mkOption {
            type = lib.types.str;
            description = "Primary local username.";
          };

          homeDirectory = lib.mkOption {
            type = lib.types.str;
            default = "/home/${cfg.username}";
            description = "Home directory for the primary local user.";
          };

          fullName = lib.mkOption {
            type = lib.types.str;
            description = "Full name for the primary local user.";
          };

          emailAddress = lib.mkOption {
            type = lib.types.str;
            description = "Email address associated with the primary local user.";
          };
        };

        config = {
          sops.secrets = {
            "${passwordHashSecret}".neededForUsers = true;
            "users/root/password-hash".neededForUsers = true;

            "${privateSshKeySecret}" = {
              path = "${cfg.homeDirectory}/.ssh/id_ed25519";
              owner = cfg.username;
              group = "users";
              mode = "0600";
            };
          };

          users.users.root = {
            hashedPasswordFile = config.sops.secrets."users/root/password-hash".path;
            openssh.authorizedKeys.keys = inputs.woodservant-pki.lib.sshAuthorizedKeys.root;
          };

          users.users.${cfg.username} = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets.${passwordHashSecret}.path;
            shell = pkgs.zsh;
            openssh.authorizedKeys.keys = inputs.woodservant-pki.lib.sshAuthorizedKeys.nixos-user;
            extraGroups = [
              "wheel"
              "networkmanager"
              "audio"
              "video"
            ];
          };

          services.openssh = {
            enable = true;
            settings = {
              PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
              PermitRootLogin = "prohibit-password";
            };
          };

          systemd.tmpfiles.rules = [
            "d ${cfg.homeDirectory}/.ssh 0700 ${cfg.username} users -"
          ];
        };
      };

  };
}
