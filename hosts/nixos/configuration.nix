# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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
    ../../modules/virtualisation.nix
    ../../modules/desktop/kde.nix
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

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

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
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    pulseaudio.enable = false;

    # Display manager and desktop are configured in modules/desktop/kde.nix

    # Enable CUPS to print documents.
    printing.enable = true;

    udev.packages = with pkgs; [
      android-udev-rules
    ];
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.alexander = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "adbusers"
        "docker"
        "networkmanager"
      ];
    };
  };

  programs = {
    thunderbird.enable = true;
    adb.enable = true;

    nix-ld = {
      enable = true;
      libraries = [
        # add dynamic libraries here
      ];
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    gamemode.enable = true;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4 --keep 3";
      };
      flake = "/home/${username}/nixos-configuration";
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      alacritty
      cacert
      firefox
      git
      keepassxc
      nvidia-container-toolkit
      vim
      wget
    ];
    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
      EDITOR = "nvim";
      TERMINAL = "kitty";
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    # Modern approach for store optimization
    optimise.automatic = true;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  # Set Alacritty as the default terminal emulator
  xdg.mime.defaultApplications = {
    "x-scheme-handler/terminal" = "alacritty.desktop";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  hardware = {
    graphics.enable = true;
    nvidia = {
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      prime = {
        offload.enable = true;
        # integrated
        amdgpuBusId = "PCI:5:0:0";
        # dedicated
        nvidiaBusId = "PCI:1:0:0";
      };
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    nvidia-container-toolkit.enable = true;
  };

  # Networking
  networking.networkmanager.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
