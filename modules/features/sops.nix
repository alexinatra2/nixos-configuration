{ self, inputs, ... }:
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
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/alexander/.config/sops/age/keys.txt";

	secrets = {
	  example-key = { };

	  "myservice/my_subdir/my_secret" = { 
	    owner = user;
	  };
	};
      };
    };

  flake.modules.homeManager.sops =
    { pkgs, config, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      home.packages = with pkgs; [
        sops
        age
      ];

      home.sessionVariables = {
        SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
