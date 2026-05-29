{ lib, ... }:
let
  hostName = "warden";
  adminUser = "alexander";
  atlasSyncthingId = "NPPGEFJ-GNQJVKL-OVEVTVE-JWJQEBD-TQ5RZSO-PW557BU-YTIYV3N-GSCBNAS";
  vaultwardenSnapshotPath = "/home/alexander/Documents/Backups/Vaultwarden";
in
{
  imports = [ ./hardware.nix ];

  sops.secrets."vaultwarden/env" = {
    owner = "vaultwarden";
    restartUnits = [ "vaultwarden.service" ];
    sopsFile = ./secrets.yaml;
  };

  networking = {
    hostName = hostName;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      interfaces.tailscale0.allowedTCPPorts = [ 22 ];
    };
  };

  local.syncthing = {
    enable = true;
    devices.atlas.id = atlasSyncthingId;
    folders.vaultwardenSnapshots = {
      id = "vaultwarden-snapshots";
      label = "Vaultwarden Snapshots";
      path = vaultwardenSnapshotPath;
      type = "sendonly";
      devices = [ "atlas" ];
    };
  };

  local.prometheus = {
    enable = true;
    listenAddress = "0.0.0.0";
    tailscaleScrape.enable = true;
  };

  local.shell.toolset = "minimal";

  sops.age = {
    # Derive the age identity from the copied SSH host key so first boot can
    # decrypt secrets immediately after nixos-anywhere installs the machine.
    keyFile = lib.mkForce null;
    generateKey = lib.mkForce false;
    sshKeyPaths = lib.mkForce [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot.tmp.cleanOnBoot = true;

  system.stateVersion = "26.05";
}
