{ self, inputs, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  flake.nixosModules.sops =
    { pkgs, config, ... }:
    let
      user = config.users.users.alexander.name;
    in
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

	# secrets will be output to /run/secrets
	secrets = {
	  alexander-password = {
	    owner = user;
	  };
	};
      };
    };

  flake.modules.homeManager.sops =
    { pkgs, config, ... }:
    let
      homeDir = config.home.homeDirectory;
    in
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      home.packages = with pkgs; [
        sops
        age
      ];

      home.sessionVariables = {
        SOPS_AGE_KEY_FILE = "${homeDir}/.config/sops/age/keys.txt";
      };

      sops = { 
        age.keyFile = "${homeDir}/.config/sops/age/keys.txt";

        defaultSopsFile = "${secretspath}/secrets.yaml";
	validateSopsFiles = false;

	secrets = {
	  "private_keys/alexander" = {
	    path = "${homeDir}/.ssh/id_ed25519";
	  };
	};
      };
    };
}
