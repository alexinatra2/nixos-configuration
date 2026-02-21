{
  flake.modules.nixos.desktop =
    { config, pkgs, ... }:
    {
      services.xserver = {
        enable = true;
        videoDrivers = [
          "nvidia"
          "modesetting"
        ];
        xkb.layout = "gb";
      };

      # Required for DisplayLink (EVDI kernel module)
      boot.extraModulePackages = with config.boot.kernelPackages; [ evdi ];

      # Optional: ensure the DisplayLink userspace service is available
      services.udev.packages = with pkgs; [ displaylink ];

      # Enable CUPS to print documents
      services.printing.enable = true;

      # KDE Plasma 6 + SDDM (Wayland by default; X11 available)
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };

      services.desktopManager.plasma6.enable = true;

      # Audio stack
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      services.pulseaudio.enable = false;

      # Basic KDE utilities
      environment.systemPackages = with pkgs; [
        kdePackages.konsole
        kdePackages.kdeconnect-kde
        kdePackages.plasma-nm
        displaylink
      ];

      environment.variables = {
        KWIN_DRM_PREFER_COLOR_DEPTH = "24";
      };

      # Allow xdg portals
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
      };

      # Console keymap
      console.useXkbConfig = true;

      security.rtkit.enable = true;

      # Fonts
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
      # Bluetooth
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General.Experimental = true;
      };

      # Graphics
      hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.mesa ];
      };

      # NVIDIA
      hardware.nvidia.open = true;

      # Networking
      networking.networkmanager.enable = true;
    };
}
