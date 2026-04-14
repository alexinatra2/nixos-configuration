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

      virtualisation = {
        containers.enable = true;
        podman.enable = true;
        docker.enable = true;
        libvirtd = {
          qemu.swtpm.enable = true;
          enable = true;
        };

        spiceUSBRedirection.enable = true;
      };

      security.rtkit.enable = true;
    };
}
