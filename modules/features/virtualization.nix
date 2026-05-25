{ self, inputs, ... }:
let
  username = "alexander";
in
{
  flake.nixosModules.virtualization =
    {
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

      users.groups.libvirtd.members = [ "${username}" ];

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

      security.rtkit.enable = true;
    };
}
