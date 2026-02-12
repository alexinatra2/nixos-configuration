# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  pkgs,
  config,
  inputs,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.stylix.nixosModules.stylix
    ../../modules/common.nix
    ../../modules/linux/nixos-locale.nix
    ../../modules/linux/nixos-packages.nix
    ../../modules/virtualisation.nix
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = false;
    # Enable GRUB
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      default = "saved";
      gfxmodeEfi = "2880x1800";
      font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
      fontSize = 24;
    };
    efi.canTouchEfiVariables = true;
  };

  # Select internationalisation properties.
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
      LC_TIME = "de_DE.UTF-8";
    };
  };

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;
      videoDrivers = [
        "nvidia"
        "displaylink"
      ];
      xkb = {
        layout = "gb";
        variant = "";
      };

      autoRepeatDelay = 250;
      autoRepeatInterval = 250;
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

  # Basic KDE utilities and network applet for Wi‑Fi control in Plasma
  environment.systemPackages = with pkgs; [
    kdePackages.konsole
    kdePackages.kdeconnect-kde
    kdePackages.plasma-nm # NetworkManager applet for KDE (Wi‑Fi controls)
  ];

  # Allow xdg portals to provide desktop integration for apps
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  # Configure console keymap (inherit from X11)
  console.useXkbConfig = true;

  security.rtkit.enable = true;

  # User configuration is now handled by shared modules
  # Additional NixOS-specific groups are in nixos-packages.nix

  # Programs are now handled by shared and Linux-specific modules
  programs.bash.enable = true;

  # Environment and packages are now handled by shared and Linux-specific modules

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

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

  # Networking
  networking.networkmanager.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05";
}
