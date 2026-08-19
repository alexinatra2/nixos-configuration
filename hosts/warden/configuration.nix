{
  config,
  lib,
  self,
  ...
}:
let
  hostName = "warden";
  atlasSyncthingId = "NPPGEFJ-GNQJVKL-OVEVTVE-JWJQEBD-TQ5RZSO-PW557BU-YTIYV3N-GSCBNAS";
in
{
  imports = with self.nixosModules; [
    ./hardware-configuration.nix
    base
    sops
    prometheus
    shell
    syncthing
    vaultwarden
  ];

  sops.secrets = {
    "vaultwarden/env" = {
      owner = "vaultwarden";
      restartUnits = [ "vaultwarden.service" ];
      sopsFile = ./secrets.yaml;
    };

    "hetzner-token" = {
      owner = "root";
      group = "root";
      mode = "0400";
      sopsFile = ./secrets.yaml;
    };
  };

  local.vaultwarden = {
    hostName = "warden.woodservant.com";
    dnsProvider = "hetzner";
    dnsCredentialFiles = {
      HETZNER_API_TOKEN_FILE = config.sops.secrets."hetzner-token".path;
    };
  };

  nebula.identity = "warden";

  networking = {
    hostName = hostName;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      interfaces = {
        nebula0.allowedTCPPorts = [
          22
          config.services.prometheus.exporters.node.port
        ];
      };
    };
  };

  local.syncthing = {
    enable = true;
    secrets = {
      cert.name = "syncthing/cert";
      cert.sopsFile = ./secrets.yaml;
      key.name = "syncthing/key";
      key.sopsFile = ./secrets.yaml;
    };
    devices.atlas.id = atlasSyncthingId;
    folders.vaultwardenSnapshots = {
      id = "vaultwarden-snapshots";
      label = "Vaultwarden Snapshots";
      path = config.local.vaultwarden.snapshotDirectory;
      type = "sendonly";
      devices = [ "atlas" ];
    };
  };

  local.prometheus = {
    enable = true;
    listenAddress = "0.0.0.0";
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
