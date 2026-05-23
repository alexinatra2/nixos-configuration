{ inputs, ... }:
{
  flake.nixosModules.grub =
    {
      pkgs,
      lib,
      ...
    }:
    let
      swapFile = "/var/swapfile";
      swapSize = "16G";
    in
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

      swapDevices = [
        {
          device = swapFile;
        }
      ];

      systemd.services.ensure-swapfile = {
        description = "Create swapfile before activation";
        before = [ "var-swapfile.swap" ];
        requiredBy = [ "var-swapfile.swap" ];
        after = [ "local-fs.target" ];
        unitConfig.ConditionPathExists = "!${swapFile}";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "ensure-swapfile" ''
            set -euo pipefail

            ${pkgs.coreutils}/bin/mkdir -p ${builtins.dirOf swapFile}
            ${pkgs.util-linux}/bin/fallocate -l ${swapSize} ${swapFile}
            ${pkgs.coreutils}/bin/chmod 600 ${swapFile}
            ${pkgs.util-linux}/bin/mkswap ${swapFile}
          '';
        };
      };
    };
}
