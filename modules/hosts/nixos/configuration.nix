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

        displayManager.sddm.enable = true;

        # Enable CUPS to print documents.
        printing.enable = true;

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

      # networking.hostName = ${hostName};

      # Configure network connections interactively with nmcli or nmtui.
      networking.networkmanager.enable = true;

      system.stateVersion = "25.11"; # Did you read the comment?
    };
}
