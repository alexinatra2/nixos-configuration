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
        default = "${config.local.base.homeDirectory}/.config/sops/age/keys.txt";
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
}
