{ self, ... }:
let
  user = "alexander";
  passwordHashSecret = "users/${user}/password-hash";
in
{
  flake.nixosModules.user-alexander =
    { pkgs, config, ... }:
    {
      sops.secrets = {
        "${passwordHashSecret}" = {
          key = passwordHashSecret;
          neededForUsers = true;
        };
      };

      users.mutableUsers = false;

      users.users.${user} = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.${passwordHashSecret}.path;
        shell = pkgs.zsh;

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
    };
}
