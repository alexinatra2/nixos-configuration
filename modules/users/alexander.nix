{ self, inputs, ... }:
{
  flake.nixosModules.user-alexander =
    { pkgs, config, ... }:
    {
      sops.secrets.alexander-password.neededForUsers = true;
      users.mutableUsers = false;

      users.users.alexander = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.alexander-password.path;
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
