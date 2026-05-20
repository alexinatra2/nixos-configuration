{
  self,
  inputs,
  ...
}:
let
  hostName = "warden";
  adminUser = "alexander";
  nixosSyncthingId = "NPPGEFJ-GNQJVKL-OVEVTVE-JWJQEBD-TQ5RZSO-PW557BU-YTIYV3N-GSCBNAS";
  vaultwardenSnapshotPath = "/home/alexander/Documents/Backups/Vaultwarden";
in
{
  flake.nixosModules.${hostName} =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      imports = [ self.nixosModules."${hostName}Hardware" ];

      sops.secrets."vaultwarden/env" = {
        owner = "vaultwarden";
        restartUnits = [ "vaultwarden.service" ];
      };

      networking = {
        hostName = hostName;
        useDHCP = lib.mkDefault true;
        firewall = {
          enable = true;
          allowedTCPPorts = [ ];
          allowedUDPPorts = [ ];
          interfaces.tailscale0.allowedTCPPorts = [
            22
            443
          ];
        };
      };

      local.syncthing = {
        enable = true;
        secrets = {
          cert = {
            name = "syncthing/warden/cert";
            owner = adminUser;
          };
          key = {
            name = "syncthing/warden/key";
            owner = adminUser;
          };
        };
        devices = {
          nixos = {
            id = nixosSyncthingId;
          };
        };
        folders = {
          vaultwardenSnapshots = {
            id = "vaultwarden-snapshots";
            label = "Vaultwarden Snapshots";
            path = vaultwardenSnapshotPath;
            type = "sendonly";
            devices = [ "nixos" ];
          };
        };
      };

      time.timeZone = "Europe/Berlin";

      i18n.defaultLocale = "en_GB.UTF-8";

      nix = {
        enable = true;
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        optimise.automatic = true;
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      };

      sops.age = {
        # Derive the age identity from the copied SSH host key so first boot can
        # decrypt secrets immediately after nixos-anywhere installs the machine.
        keyFile = lib.mkForce null;
        generateKey = lib.mkForce false;
        sshKeyPaths = lib.mkForce [ "/etc/ssh/ssh_host_ed25519_key" ];
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      users.users.${adminUser}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXXZ3nXj+cIsv0NUuxQ971Cx2haGWudOa+C3ujb0zG+ alexander@nixos"
      ];

      environment.systemPackages = with pkgs; [
        git
      ];

      programs.zsh.enable = true;

      boot.tmp.cleanOnBoot = true;

      system.stateVersion = "26.05";
    };
}
