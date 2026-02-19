# Virtualisation configuration (NixOS only)
{ ... }:
{
  flake.modules.nixos.virtualisation =
    { pkgs, ... }:
    {
      virtualisation = {
        containers.enable = true;
        podman.enable = true;
        docker.enable = true;
        libvirtd.enable = true;
        spiceUSBRedirection.enable = true;
      };

      environment.systemPackages = with pkgs; [
        dive
        podman-tui
        docker-compose
      ];

      users.groups.libvirtd.members = [ "alexander" ];
    };
}
