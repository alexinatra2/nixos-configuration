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
    { pkgs, ... }:
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

        # Automatic optimization only works on NixOS
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

        # Enable CUPS to print documents.
        printing.enable = true;

        # Recommended audio stack
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };

        pulseaudio.enable = false;
      };

      # Allow xdg portals to provide desktop integration for apps
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      };

      # networking.hostName = ${hostName};

      # Configure network connections interactively with nmcli or nmtui.
      networking.networkmanager.enable = true;

      security.polkit.enable = true;
      security.rtkit.enable = true;

      services.blueman.enable = true;

      system.stateVersion = "24.05";
    };
}
