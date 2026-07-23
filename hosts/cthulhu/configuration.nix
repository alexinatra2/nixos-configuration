{ lib, self, ... }:
{
  imports = with self.nixosModules; [
    ./hardware-configuration.nix
    ./agents.nix
    base
    shell
    sops
    tailscale
    zramCompression
  ];

  networking = {
    hostName = "cthulhu";
    firewall.allowedTCPPorts = [ 22 ];
  };

  local = {
    shell.toolset = "minimal";

    # This host has no Headscale enrollment until its bare-metal deployment.
    tailscale.enable = lib.mkForce false;
  };

  boot.tmp.cleanOnBoot = true;

  virtualisation = {
    docker.enable = true;

    vmVariantWithBootLoader = {
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      users = {
        mutableUsers = true;
        users.alexander = {
          hashedPasswordFile = lib.mkForce null;
          initialPassword = "cthulhu";
        };
        users.root.hashedPasswordFile = lib.mkForce null;
      };

      # The disposable VM must not need the future bare-metal host key.
      sops.secrets = {
        "users/alexander/password-hash".neededForUsers = lib.mkForce false;
        "users/root/password-hash".neededForUsers = lib.mkForce false;
      };
      system.activationScripts.validatePasswordHashSecrets = lib.mkForce "";

      virtualisation = {
        cores = 4;
        memorySize = 8192;
        diskSize = 32768;
        forwardPorts = [
          {
            from = "host";
            host.port = 2222;
            guest.port = 22;
          }
        ];
      };
    };
  };

  system.stateVersion = "26.05";
}
