{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  boot.initrd.systemd.enable = true;

  boot.lanzaboote = {
    configurationLimit = 8;
    measuredBoot = {
      enable = true;
      pcrs = [
        0
        4
        7
      ];
      autoCryptenroll = {
        enable = true;
        device = "/dev/disk/by-id/nvme-WD_Blue_SN570_1TB_231429805907-part1";
      };
    };
  };

  environment.etc."crypttab".text = ''
    data /dev/disk/by-id/nvme-WD_Blue_SN570_1TB_231429805907-part1 - tpm2-device=auto
  '';

  disko.devices.disk.data = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-WD_Blue_SN570_1TB_231429805907";

    content = {
      type = "gpt";
      partitions.crypt = {
        size = "100%";
        content = {
          type = "luks";
          name = "data";

          content = {
            type = "btrfs";
            extraArgs = [
              "-L"
              "data"
            ];
            subvolumes = {
              "/vms" = {
                mountpoint = "/srv/vms";
                mountOptions = [ "x-systemd.requires=systemd-cryptsetup@data.service" ];
              };
              "/shared" = {
                mountpoint = "/srv/shared";
                mountOptions = [ "x-systemd.requires=systemd-cryptsetup@data.service" ];
              };
              "/backup-staging" = {
                mountpoint = "/srv/backup-staging";
                mountOptions = [ "x-systemd.requires=systemd-cryptsetup@data.service" ];
              };
            };
          };
        };
      };
    };
  };
}
