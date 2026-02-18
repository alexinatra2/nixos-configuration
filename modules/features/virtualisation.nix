{
  flake.modules.nixos =
    { pkgs, ... }:
    {
      virtualisation = {
        virtualisation = {
          containers.enable = true;
          podman.enable = true;
          docker.enable = true;
          libvirtd.enable = true;
          spiceUSBRedirection.enable = true;
        };

        # Container development tools
        environment.systemPackages = with pkgs; [
          dive
          podman-tui
          docker-compose
        ];

        users.groups.libvirtd.members = [ "alexander" ];
      };
    };
}
