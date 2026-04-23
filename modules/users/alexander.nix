{ self, inputs, ... }:
let
  user = "alexander";
  sops-password-key = "${user}-password";
in
{
  flake.nixosModules.user-alexander =
    { pkgs, config, ... }:
    {
      sops.secrets = { 
	"${sops-password-key}" = {
	  owner = user;
	  neededForUsers = true;
	};
      };

      users.mutableUsers = false;

      users.users.${user} = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.${sops-password-key}.path;
        shell = pkgs.zsh;

        extraGroups = [
          "wheel"
          "adbusers"
          "docker"
          "networkmanager"
          "realtime"
          "audio"
          "video"
        ];
      };
    };
}
