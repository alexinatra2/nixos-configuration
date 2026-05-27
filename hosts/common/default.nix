{ self, inputs, ... }:
{
  imports = [
    self.nixosModules.sops
    self.nixosModules.tailscale
    self.nixosModules.user-alexander
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  security.pki.certificateFiles = [
    ./certs/woodservant-tailnet-root-ca.crt
  ];

  local.tailscale = {
    enable = true;
    authKeySecretName = "headscale/authkey";
    loginServer = "https://headscale.woodservant.com";
    expectedTailnet = "tailnet.woodservant.com";
    tags = [ ];
  };

  i18n.defaultLocale = "en_GB.UTF-8";

  time.timeZone = "Europe/Berlin";

  nix = {
    enable = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "alexander" ];
    };
    optimise.automatic = true;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
