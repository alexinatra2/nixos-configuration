{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

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
          initrdUnlock = true;

          content = {
            type = "btrfs";
            extraArgs = [
              "-L"
              "data"
            ];
            subvolumes = {
              "/vms".mountpoint = "/srv/vms";
              "/shared".mountpoint = "/srv/shared";
              "/backup-staging".mountpoint = "/srv/backup-staging";
            };
          };
        };
      };
    };
  };
}
