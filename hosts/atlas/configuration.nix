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
  nixvimPackage = inputs.nixvim-config.packages.x86_64-linux.default;
  wardenSyncthingId = "2ZRIH3H-CZ7QK7O-SVRSS43-E6YUF6U-CGNTKH5-4372Y4P-YSNMN5G-7GDIJAL";
  vaultwardenSnapshotPath = "${homeDirectory}/Documents/Backups/Vaultwarden";
in
{
  imports = with self.nixosModules; [
    ./hardware-configuration.nix
    base
    sops
    tailscale
    shell
    tmuxRemote
    niri
    greeter
    git
    displaylink
    gaming
    virtualization
    fonts
    stylix
    grub
    syncthing
    llms
    index
    tmux
    windows
    zramCompression
    yubikey
    work
  ];

  networking.hostName = hostName;

  local.shell = {
    toolset = "maximal";
    editorPackage = nixvimPackage;
  };
  local.niri.picker = "vicinae";
  local.tmuxRemote.niriTerminalOverride.enable = true;
  local.yubikey.enable = true;
  local.yubikey.pamAuth.services.sudo = false;

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

  programs.nh = {
    enable = true;
    flake = "${homeDirectory}/nixos-configuration";
    clean.enable = false;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_6_6;
    extraModprobeConfig = ''
      options btusb enable_autosuspend=n reset=1
    '';
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
    services.bluetooth-unblock = {
      description = "Unblock Bluetooth on boot";
      wantedBy = [ "multi-user.target" ];
      after = [ "bluetooth.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
      };
    };

    services.systemd-rfkill.enable = false;
    sockets.systemd-rfkill.enable = false;
  };

  system.activationScripts.clearBluetoothRfkill = lib.stringAfter [ "users" ] ''
    rm -f /var/lib/systemd/rfkill/*bluetooth || true
  '';

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
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
