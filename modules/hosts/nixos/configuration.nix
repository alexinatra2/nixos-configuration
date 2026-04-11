{ self, inputs, ... }:
let
  hostName = "nixos";
  username = "alexander";
in
{
  flake.nixosModules.${hostName} =
    { pkgs, lib, ... }:
    {
      imports = [
        self.nixosModules."${hostName}Hardware"
      ];

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

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

      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "adbusers"
          "docker"
          "networkmanager"
          "realtime"
          "audio"
        ];
      };

      hardware = {
        bluetooth = {
          enable = true;
          powerOnBoot = true;
          settings.General.Experimental = true;
        };

        graphics = {
          enable = true;
          extraPackages = [ pkgs.mesa ];
        };

        nvidia.open = true;
      };

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        prime = {
          offload.enable = true;
          amdgpuBusId = "PCI:5:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };

      services = {
        xserver = {
          enable = true;
          videoDrivers = [
            "nvidia"
            "amdgpu"
            "displaylink"
          ];
          xkb = {
            layout = "us,de";
            variant = "";
          };
        };

        # Enable CUPS to print documents.
        printing.enable = true;

        # KDE Plasma 6 + SDDM (Wayland by default; X11 available)
        displayManager.sddm = {
          enable = true;
          wayland.enable = true;
          # You can set a theme here later, e.g.:
          # theme = "catppuccin-mocha";
        };

        desktopManager.plasma6.enable = true;

        # Recommended audio stack; KDE uses PipeWire well
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };
        pulseaudio.enable = false;
      };

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

      # Timezone
      time.timeZone = "Europe/Berlin";

      # networking.hostName = ${hostName};

      # Configure network connections interactively with nmcli or nmtui.
      networking.networkmanager.enable = true;

      system.stateVersion = "25.11"; # Did you read the comment?
    };
}
