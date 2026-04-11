{ self, inputs, ... }:
let
  hostName = "nixos";
in
{
  flake.nixosModules."${hostName}Hardware" =
    { pkgs, lib, modulesPath, config, ... }:

    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
        "rtsx_pci_sdmmc"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/73774a44-9f77-447a-8d46-f88a773e3bac";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/D367-3000";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      fileSystems."/var/lib/docker/overlay2/07820b34138842c8768caff88684ee7284a9f74e6fe59408c07fc10f89e1dd38/merged" =
        {
          device = "overlay";
          fsType = "overlay";
        };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
