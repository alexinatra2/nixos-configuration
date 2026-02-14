{
  pkgs,
  username,
  ...
}:
{
  virtualisation = {
    containers.enable = true;
    podman.enable = true;
    docker.enable = true;
    libvirtd.enable = true;

    spiceUSBRedirection.enable = true;
  };

  # Useful container development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
  ];

  users.groups.libvirtd.members = [ "${username}" ];
}
