{ config, inputs, ... }:
{
  imports = [
    inputs.woodservant-pki.nixosModules.default
  ];

  local.base = {
    username = "alexander";
    fullName = "Alexander Holzknecht";
    emailAddress = "alexander@woodservant.com";
  };

  networking.domain = "woodservant.com";

  nixpkgs.config.allowUnfree = true;

  nix = {
    enable = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ config.local.base.username ];
    };
    optimise.automatic = true;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  sops.defaultSopsFile = ./common/secrets.yaml;

  networking.networkmanager.enable = true;

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  time.timeZone = "Europe/Berlin";
}
