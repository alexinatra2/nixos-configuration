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
        rootPasswordHashSecret = "users/root/password-hash";
        privateSshKeySecret = "users/${cfg.username}/private-ssh-key";

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
            "${rootPasswordHashSecret}".neededForUsers = true;

            "${privateSshKeySecret}" = {
              path = "${cfg.homeDirectory}/.ssh/id_ed25519";
              owner = cfg.username;
              group = "users";
              mode = "0600";
            };
          };

          users.users.root = {
            hashedPasswordFile = config.sops.secrets.${rootPasswordHashSecret}.path;
            openssh.authorizedKeys.keys = yubikeyKeys;
          };

          users.users.${cfg.username} = {
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
            "d ${cfg.homeDirectory}/.ssh 0700 ${cfg.username} users -"
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

              check_hash_file "${cfg.username}" "${config.sops.secrets.${passwordHashSecret}.path}"
              check_hash_file "root" "${config.sops.secrets.${rootPasswordHashSecret}.path}"
            '';
          };
        };
      };

    modules.homeManager.base =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options.local.base = {
          username = lib.mkOption {
            type = lib.types.str;
            default = config.home.username;
            description = "Primary local username.";
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

        home = {
          packages = with pkgs; [
            gcc
            jdk21
            lazydocker
            lazysql
            nixfmt
            nodejs
            pnpm
            fd
            ripgrep
            tree
            unzip
            yazi
            typst
            just
            telegram-desktop
            bc
            uutils-coreutils-noprefix
            spotify
            ausweisapp
            xclip
            disktui
            (writeShellApplication {
              name = "ns";
              runtimeInputs = [
                fzf
                nix-search-tv
              ];
              text = builtins.readFile "${nix-search-tv.src}/nixpkgs.sh";
            })
            (writeShellApplication {
              name = "vim-temp";
              runtimeInputs = [ neovim ];
              text = ''
                if [ $# -eq 0 ]; then
                  echo "Usage: vim-temp <command> [args...]" >&2
                  exit 1
                fi
                nvim -R <( "$@" 2>&1 )
              '';
            })
          ];
          stateVersion = "26.05";
        };

        programs.home-manager.enable = true;

        nixpkgs.config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
  };
}
