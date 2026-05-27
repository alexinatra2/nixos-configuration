{ lib, ... }:
let
  hostName = "sentinel";
  atlasSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXXZ3nXj+cIsv0NUuxQ971Cx2haGWudOa+C3ujb0zG+ alexander@atlas";
in
{
  imports = [ ./hardware.nix ];

  networking = {
    hostName = hostName;
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      interfaces.tailscale0.allowedTCPPorts = [ 22 ];
    };
  };

  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.kernelModules = [
      "sdhci_pci"
      "sdhci"
      "cqhci"
      "mmc_block"
    ];

    kernelParams = [
      "rootdelay=10"
      "mmc_core.removable=0"
      "sdhci.debug_quirks2=4"
      "mmc_cmdqueue=0"
    ];
  };

  sops.age = {
    keyFile = lib.mkForce null;
    generateKey = lib.mkForce false;
    sshKeyPaths = lib.mkForce [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  local.shell.toolset = "minimal";

  services.openssh.settings.PermitRootLogin = "prohibit-password";

  users.users.root.openssh.authorizedKeys.keys = lib.mkAfter [ atlasSshKey ];
  users.users.alexander.openssh.authorizedKeys.keys = lib.mkAfter [ atlasSshKey ];

  boot.tmp.cleanOnBoot = true;

  hardware = {
    bluetooth.enable = false;
    enableRedistributableFirmware = lib.mkDefault true;
  };

  system.stateVersion = "25.11";
}
