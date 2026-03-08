{
  pkgs,
  username,
  ...
}:
{
  programs.virt-manager.enable = true;

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

  # Useful container development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev

    quickemu
    # needed for display==spice-app in quickemu
    virt-viewer

    virt-manager
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
  ];

  users.groups.libvirtd.members = [ "${username}" ];

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };
  users.users.${username}.extraGroups = [ "tss" ];
}
