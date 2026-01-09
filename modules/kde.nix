{
  pkgs,
  config,
  lib,
  ...
}:
{
  # KDE Plasma 6 + SDDM (Wayland by default; X11 available)
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # You can set a theme here later, e.g.:
    # theme = "catppuccin-mocha";
  };

  services.desktopManager.plasma6.enable = true;

  # Recommended audio stack; KDE uses PipeWire well
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.pulseaudio.enable = false;

  # Basic KDE utilities and network applet for Wi‑Fi control in Plasma
  environment.systemPackages = with pkgs; [
    kdePackages.konsole
    kdePackages.kdeconnect-kde
    kdePackages.plasma-nm # NetworkManager applet for KDE (Wi‑Fi controls)
  ];

  # Enable hardware acceleration helpers if not already set at host level
  hardware.graphics.enable = lib.mkDefault true;

  # Allow xdg portals to provide desktop integration for apps
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
  };
}
