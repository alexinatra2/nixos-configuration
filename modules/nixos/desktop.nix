{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      # Enable the X11 windowing system
      services.xserver = {
        enable = true;
        videoDrivers = [
          "nvidia"
          "displaylink"
        ];
        xkb = {
          layout = "gb";
          variant = "";
        };
      };

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
      ];

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
