{ self, inputs, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  flake.nixosModules.sops =
    { pkgs, config, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      environment.systemPackages = with pkgs; [
        sops
        age
      ];

      sops = {
        defaultSopsFile = "${secretspath}/secrets.yaml";
        defaultSopsFormat = "yaml";
        age = {
	  sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
	  keyFile = "/home/alexander/.config/sops/age/keys.txt";
	  generateKey = true;	
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
        (writeShellApplication {
          name = "update-secrets";
          runtimeInputs = [
            git
            nix
          ];
          text = ''
            set -euo pipefail

            repo_root="${homeDir}/nixos-configuration"

            if [ ! -d "$repo_root/.git" ]; then
              echo "Not a git repo: $repo_root" >&2
              exit 1
            fi

            echo "Updating flake input 'secrets' in $repo_root"
            nix flake update secrets --flake "$repo_root"

            echo
            echo "Done. Current lockfile changes:"
            git -C "$repo_root" status --short -- flake.lock
          '';
        })
      ];

      sops = { 
        age.keyFile = "${homeDir}/.config/sops/age/keys.txt";

        defaultSopsFile = "${secretspath}/secrets.yaml";
	validateSopsFiles = false;

	secrets = {
	  "private_keys/${username}" = {
	    path = "${homeDir}/.ssh/id_ed25519";
	  };
	};
      };
    };
}
