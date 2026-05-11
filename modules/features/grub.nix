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

        # Lanzaboote replaces the standard systemd-boot module.
        systemd-boot.enable = lib.mkForce false;
      };

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
}
