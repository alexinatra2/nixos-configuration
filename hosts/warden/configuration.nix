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
    tailscale
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

    "vaultwarden/tls/cert" = {
      owner = "nginx";
      group = "nginx";
      mode = "0440";
      restartUnits = [ "nginx.service" ];
      sopsFile = ./secrets.yaml;
    };

    "vaultwarden/tls/key" = {
      owner = "nginx";
      group = "nginx";
      mode = "0440";
      restartUnits = [ "nginx.service" ];
      sopsFile = ./secrets.yaml;
    };
  };

  local.vaultwarden = {
    tlsCertificate = config.sops.secrets."vaultwarden/tls/cert".path;
    tlsCertificateKey = config.sops.secrets."vaultwarden/tls/key".path;
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
