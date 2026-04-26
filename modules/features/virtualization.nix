{ self, inputs, ... }:
let
  username = "alexander";
in
{
  flake.nixosModules.virtualization =
    {
      pkgs,
      ...
    }:
    {
      programs.virt-manager.enable = true;

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

      security.rtkit.enable = true;
    };
}
