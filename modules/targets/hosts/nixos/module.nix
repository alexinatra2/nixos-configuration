{
  self,
  inputs,
  config,
  ...
}:
let
  hostName = "nixos";
in
{
  flake.nixosModules.${hostName} =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules."${hostName}Hardware"
      ];

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

      nix = {
        enable = true;

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };

        optimise.automatic = true;
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      };

      nixpkgs.config.allowUnfree = true;

      programs.zsh.enable = true;

      hardware = {
        bluetooth = {
          enable = true;
          powerOnBoot = true;
        };

        graphics = {
          enable = true;
          extraPackages = [ pkgs.mesa ];
        };

        nvidia = {
          open = true;
          modesetting.enable = true;
          powerManagement.enable = true;
          prime = {
            offload.enable = true;
            amdgpuBusId = "PCI:5:0:0";
            nvidiaBusId = "PCI:1:0:0";
          };
        };
      };

      services = {
        fprintd = {
          enable = true;
          tod = {
            enable = true;
            driver = pkgs.libfprint-2-tod1-goodix-550a;
          };
        };

        upower.enable = true;

        xserver = {
          enable = true;
          videoDrivers = [
            "nvidia"
            "amdgpu"
          ];
          xkb = {
            layout = "us,de";
            variant = "";
          };
        };

        printing.enable = true;

        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };

        pulseaudio.enable = false;
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      };

      networking.networkmanager.enable = true;

      security.polkit.enable = true;
      security.soteria.enable = true;
      security.rtkit.enable = true;

      security.pam.services = {
        ly = {
          fprintAuth = true;
          unixAuth = true;
          enableGnomeKeyring = lib.mkForce false;
        };
        login = {
          fprintAuth = true;
          unixAuth = true;
          enableGnomeKeyring = lib.mkForce false;
        };
        sudo.fprintAuth = false;
        "polkit-1" = {
          fprintAuth = true;
          unixAuth = true;
        };
      };

      services.blueman.enable = true;

      system.stateVersion = "24.05";
    };
}
