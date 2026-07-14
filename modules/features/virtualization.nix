{ self, inputs, ... }:
{
  flake.nixosModules.virtualization =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.virt-manager.enable = true;

      users.groups = {
        docker = { };
        podman = { };
      };

      users.users.${config.local.base.username}.extraGroups = [
        "docker"
        "podman"
      ];

      users.groups.libvirtd.members = [ config.local.base.username ];

      environment.systemPackages = with pkgs; [
        podman-compose
        quickemu
        quickgui
      ];

      virtualisation = {
        containers.enable = true;

        podman = {
          enable = true;
          dockerCompat = false;
          dockerSocket.enable = false;
          defaultNetwork.settings = {
            dns_enabled = true;
          };
        };

        docker.enable = true;

        libvirtd = {
          enable = true;
          onBoot = "start";
          onShutdown = "shutdown";
          qemu = {
            package = pkgs.qemu_kvm;
            swtpm.enable = true;
          };
        };

        spiceUSBRedirection.enable = true;
      };

    };
}
