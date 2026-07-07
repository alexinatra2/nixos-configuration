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
    base
    displaylink
    fonts
    gaming
    git
    greeter
    grub
    index
    llms
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
    virtualization
    windows
    work
    xdg
    yubikey
    zramCompression
  ];

  networking.hostName = hostName;

  local.shell = {
    toolset = "maximal";
    editorPackage = nixvimPackage;
  };
  local.opencode.enable = true;
  local.work = {
    fernuni = {
      enable = true;
      username = "t_holzknecht";
      sopsFile = ./work-secrets.yaml;
    };
  };
  local.niri.picker = "vicinae";
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
    lazydocker
    lazysql
    fd
    gcc
    jq
    nerd-fonts.jetbrains-mono
    nixfmt
    pnpm
    ripgrep
    sccache
    sops
    tree
    unzip
    yazi
    just
    uutils-coreutils-noprefix
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

  services.blueman.enable = true;

  system.stateVersion = "24.05";
}
