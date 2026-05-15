{
  self,
  inputs,
  ...
}:
let
  hostName = "warden";
  adminUser = "alexander";
in
{
  flake.nixosModules.${hostName} =
    {
      lib,
      ...
    }:
    {
      imports = [ self.nixosModules."${hostName}Hardware" ];

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

      local.sops.ageKeyFile = "/var/lib/sops-nix/key.txt";

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

      environment.systemPackages = [ ];

      programs.zsh.enable = true;

      boot.tmp.cleanOnBoot = true;

      system.stateVersion = "26.05";
    };
}
