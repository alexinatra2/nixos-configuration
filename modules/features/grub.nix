{ inputs, ... }:
{
  flake.nixosModules.grub =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      environment.systemPackages = with pkgs; [
        # For debugging and troubleshooting Secure Boot.
        sbctl
      ];

      boot.loader = {
        efi.canTouchEfiVariables = true;

        # Signed kernels and initrds consume a lot of space on a 1 GiB ESP.
        # Keep only a few generations so activations do not fail when /boot fills up.
        systemd-boot.configurationLimit = 3;

        # Lanzaboote replaces the standard systemd-boot module.
        systemd-boot.enable = lib.mkForce false;
      };

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
}
