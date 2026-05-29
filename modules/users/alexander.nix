{ self, ... }:
let
  user = "alexander";
  homeDirectory = "/home/${user}";

  passwordHashSecret = "users/${user}/password-hash";
  rootPasswordHashSecret = "users/root/password-hash";
  privateSshKeySecret = "users/${user}/private-ssh-key";

  fallbackKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOL4erb/2bO2EdVfPnZ66qwpHXrS311KjA0zFm+s8HM"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXXZ3nXj+cIsv0NUuxQ971Cx2haGWudOa+C3ujb0zG+"
  ];
  yubikeyKeys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAOYKAbNhJz8559+YnbwdV2tQphlp/qxvN0PPVn1E/dlAAAABHNzaDo="
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIC6/2M/FooFnETl7rd94ggXwnWSA3topGiFAT8qiZCOYAAAABHNzaDo="
  ];
  sshKeys = fallbackKeys ++ yubikeyKeys;
in
{
  flake.nixosModules.user-alexander =
    { pkgs, config, ... }:
    {
      sops.secrets = {
        "${passwordHashSecret}" = {
          neededForUsers = true;
        };

        "${rootPasswordHashSecret}" = {
          neededForUsers = true;
        };

        "${privateSshKeySecret}" = {
          path = "${homeDirectory}/.ssh/id_ed25519";
          owner = user;
          group = "users";
          mode = "0600";
        };
      };

      users.users.root = {
        hashedPasswordFile = config.sops.secrets.${rootPasswordHashSecret}.path;

        openssh.authorizedKeys.keys = yubikeyKeys;
      };

      users.users.${user} = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.${passwordHashSecret}.path;
        shell = pkgs.zsh;

        openssh.authorizedKeys.keys = sshKeys;

        extraGroups = [
          "wheel"
          "adbusers"
          "docker"
          "podman"
          "networkmanager"
          "realtime"
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
        "d ${homeDirectory}/.ssh 0700 ${user} users -"
      ];

      system.activationScripts.validatePasswordHashSecrets = {
        deps = [ "users" ];
        text = ''
          # sops-nix validates encrypted files during evaluation; this validates
          # the decrypted password-hash payloads before we finish activation.
          check_hash_file() {
            name="$1"
            hashFile="$2"

            if [ ! -s "$hashFile" ]; then
              echo "ERROR: password hash secret for $name is missing or empty: $hashFile" >&2
              exit 1
            fi

            hash="$(cat "$hashFile")"

            case "$hash" in
              \$y\$*|\$6\$*|\$5\$*|\$2a\$*|\$2b\$*) ;;
              *)
                echo "ERROR: password hash secret for $name does not look valid" >&2
                exit 1
                ;;
            esac
          }

          check_hash_file "${user}" "${config.sops.secrets.${passwordHashSecret}.path}"
          check_hash_file "root" "${config.sops.secrets.${rootPasswordHashSecret}.path}"
        '';
      };
    };
}
