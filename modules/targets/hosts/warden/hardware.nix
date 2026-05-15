{ self, inputs, ... }:
let
  hostName = "warden";
in
{
  flake.nixosModules."${hostName}Hardware" =
    {
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        inputs.disko.nixosModules.disko
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.initrd.availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "sr_mod"
        "usbhid"
        "virtio_blk"
        "virtio_pci"
        "virtio_scsi"
        "xhci_pci"
      ];

      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      disko.devices = {
        disk.main = {
          type = "disk";
          device = "/dev/disk/by-id/REPLACE_WITH_YOUR_SERVER_DISK";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "512M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };

              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };

      swapDevices = [ ];

      hardware.enableRedistributableFirmware = lib.mkDefault true;
    };
}
