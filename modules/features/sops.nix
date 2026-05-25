{ self, inputs, ... }:
{
  flake.nixosModules.sops =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      options.local.sops.ageKeyFile = lib.mkOption {
        type = lib.types.str;
        default = "/home/alexander/.config/sops/age/keys.txt";
        description = "Path to the system age key used by sops-nix.";
      };

      imports = [ inputs.sops-nix.nixosModules.sops ];

      config = {
        environment.systemPackages = with pkgs; [
          sops
          age
        ];

        sops = {
          defaultSopsFormat = "yaml";
          age = {
            sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            keyFile = config.local.sops.ageKeyFile;
            generateKey = true;
          };
        };
      };
    };

  flake.modules.homeManager.sops =
    { pkgs, config, ... }:
    let
      homeDir = config.home.homeDirectory;
      username = config.home.username;
    in
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      home.packages = with pkgs; [
        sops
        age
      ];

      sops = {
        age = {
          keyFile = "${homeDir}/.config/sops/age/keys.txt";
          sshKeyPaths = [ "${homeDir}/.ssh/id_ed25519" ];
          generateKey = true;
        };

        defaultSopsFile = ../targets/hosts/secrets.yaml;
        validateSopsFiles = false;

        secrets = {
          "users/${username}/private-ssh-key" = {
            key = "private_keys/${username}";
            path = "${homeDir}/.ssh/id_ed25519";
          };
        };
      };
    };
}
