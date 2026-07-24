{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  hostName = "atlas";
  username = config.local.base.username;
  homeDirectory = config.local.base.homeDirectory;
  nixvimPackage =
    inputs.nixvim-config.packages.${pkgs.stdenv.hostPlatform.system}.default.extend
      config.stylix.targets.nixvim.exportedModule;
  wardenSyncthingId = "HH7HKXE-WI5CYZF-D7YFMEI-OKUAJXI-U4DDJP3-6RH2XDA-T3N572K-ZCMSGAF";
  vaultwardenSnapshotPath = "${homeDirectory}/Documents/Backups/Vaultwarden";
in
{
  imports = with self.nixosModules; [
    ./hardware-configuration.nix
    ./storage.nix
    agentPreferences
    base
    displaylink
    eduroam
    focusrite
    fonts
    gaming
    git
    greeter
    hermes
    secureBoot
    llms
    monitorProfiles
    music
    nh
    niri
    opencode
    shell
    sops
    stylix
    syncthing
    tailscale
    tmux
    vicinae
    virtualization
    windows
    work
    xdg
    yubikey
    zramCompression
  ];

  networking.hostName = hostName;

  boot.blacklistedKernelModules = [ "ideapad_laptop" ];

  # Preserve the original Wi-Fi interface name if PCI bus numbering changes.
  systemd.network.links."10-atlas-wifi" = {
    matchConfig.MACAddress = "2c:98:11:55:23:f3";
    linkConfig.Name = "wlo1";
  };

  local.shell = {
    toolset = "maximal";
    editorPackage = nixvimPackage;
  };
  local.opencode = {
    enable = true;
    goeranh = {
      enable = true;
      sopsFile = ./secrets.yaml;
    };
    lore = {
      enable = false;
      sopsFile = ./secrets.yaml;
    };
  };
  local.hermes = {
    enable = true;
    dashboard.enable = true;
    interactive.enable = true;
    goeranh = {
      enable = true;
      sopsFile = ./secrets.yaml;
    };
  };
  local.eduroam = {
    enable = true;
    sopsFile = ./work-secrets.yaml;
  };
  local.work = {
    fernuni = {
      enable = true;
      username = "t_holzknecht";
      sopsFile = ./work-secrets.yaml;
    };
  };
  local.monitorProfiles = {
    enable = true;
    profiles.desk.outputs = {
      "DVI-I-2" = {
        mode = "preferred";
        position = {
          x = 0;
          y = 0;
        };
      };
      "DVI-I-1" = {
        mode = "preferred";
        position = {
          x = 1920;
          y = 0;
        };
      };
    };
  };
  local.vicinae = {
    enable = true;
    githubTokenSopsFile = ./secrets.yaml;
    bitwardenCredentialsSopsFile = ./secrets.yaml;
    extensions = {
      bitwarden.enable = true;
      bluetooth.enable = true;
      firefox.enable = true;
      github.enable = true;
      niri.enable = true;
      nix.enable = true;
      player-pilot.enable = true;
      podman.enable = true;
      port-killer.enable = true;
      power-profile.enable = true;
      process-manager.enable = true;
      pulseaudio.enable = true;
      screenshot.enable = true;
      search-npm.enable = true;
      spotify-player.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
    };
    settings.providers."@jomifepe/bitwarden".preferences.serverUrl =
      "https://warden.tailnet.woodservant.com";
  };
  local.focusrite = {
    enable = true;
    defaultProfile = "teams";
  };

  local.yubikey = {
    enable = true;
    pamAuth.services.sudo = false;
  };

  sops.secrets."yubikey/main-credential" = {
    sopsFile = ./secrets.yaml;
  };
  sops.templates."users/${username}/u2f_keys" = {
    path = "${homeDirectory}/.config/Yubico/u2f_keys";
    owner = username;
    group = "users";
    mode = "0600";
    content = ''
      ${username}:${config.sops.placeholder."yubikey/main-credential"}
    '';
  };
  users.users.${username}.packages = with pkgs; [
    bc
    besley
    cargo
    disktui
    lazysql
    gcc
    jq
    nerd-fonts.jetbrains-mono
    nixfmt
    pnpm
    sccache
    sops
    tree
    unzip
    yazi
    just
    spotify
    xclip
    nixvimPackage
    nodejs
    python313Packages.huggingface-hub
    uv
  ];

  local.nh.osFlake = "${homeDirectory}/nixos-configuration";

  programs.nix-ld = {
    enable = true;
    libraries = [
    ];
  };

  hardware = {
    enableRedistributableFirmware = true;

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
      enable = false;
      tod = {
        enable = false;
        driver = pkgs.libfprint-2-tod1-goodix-550a;
      };
    };

    upower.enable = true;
    power-profiles-daemon.enable = true;

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

  systemd = {
    services.systemd-rfkill.enable = false;
    sockets.systemd-rfkill.enable = false;
  };

  users.mutableUsers = true;

  local.syncthing = {
    enable = true;
    guiUser = "alex";
    secrets = {
      password.name = "syncthing/password";
      password.sopsFile = ./secrets.yaml;
      cert.name = "syncthing/cert";
      cert.sopsFile = ./secrets.yaml;
      key.name = "syncthing/key";
      key.sopsFile = ./secrets.yaml;
    };
    devices = {
      pixel7.id = "S6GEWYT-ST3KUYP-PBEE6WG-TYKMUL7-X6UQPX2-IQOL567-5YKKBQZ-VFO3WQV";
      warden.id = wardenSyncthingId;
    };
    folders = {
      camera = {
        id = "v283i-tw1dt";
        label = "Camera";
        path = "${homeDirectory}/Pictures/Pixel7";
        type = "receiveonly";
        devices = [ "pixel7" ];
      };
      vaultwardenSnapshots = {
        id = "vaultwarden-snapshots";
        label = "Vaultwarden Snapshots";
        path = vaultwardenSnapshotPath;
        type = "receiveonly";
        devices = [ "warden" ];
      };
    };
  };

  security.polkit.enable = true;
  security.soteria.enable = true;
  security.rtkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.blueman.enable = true;

  system.stateVersion = "24.05";
}
