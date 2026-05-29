{ self, inputs, ... }:
{
  flake.nixosModules.yubikey =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.local.yubikey = {
        enable = lib.mkEnableOption "YubiKey support";
      };

      config = lib.mkIf config.local.yubikey.enable {
        services.pcscd.enable = true;

        services.gnome.gcr-ssh-agent.enable = false;

        programs.ssh.startAgent = true;

        environment.systemPackages = with pkgs; [
          yubikey-manager
          yubikey-personalization
          opensc
        ];
      };
    };
}
