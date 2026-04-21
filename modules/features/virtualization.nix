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

      users.groups.libvirtd.members = [ "${username}" ];

      environment.systemPackages = with pkgs; [
        quickemu
        quickgui
      ];

      virtualisation = {
        containers.enable = true;

        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings = {
            dns_enabled = true;
          };
        };

        docker.enable = false;

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

      specialisation = {
        native-docker.configuration = {
          virtualisation = {
            podman = {
              enable = lib.mkForce false;
              dockerCompat = lib.mkForce false;
            };
            docker.enable = lib.mkForce true;
          };
        };

        full-emulation.configuration = {
          virtualisation.libvirtd.qemu.package = lib.mkForce pkgs.qemu;
        };
      };

      security.rtkit.enable = true;
    };
}
