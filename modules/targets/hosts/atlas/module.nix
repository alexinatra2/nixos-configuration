{
  self,
  inputs,
  config,
  ...
}:
let
  hostName = "atlas";
  wardenSyncthingId = "2ZRIH3H-CZ7QK7O-SVRSS43-E6YUF6U-CGNTKH5-4372Y4P-YSNMN5G-7GDIJAL";
  vaultwardenSnapshotPath = "/home/alexander/Documents/Backups/Vaultwarden";
in
{
  flake.nixosModules.${hostName} =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules."${hostName}Hardware"
      ];

      networking.hostName = hostName;

      local.tailscale = {
        enable = true;
        authKeySecretName = "headscale/authkey";
        loginServer = "https://headscale.woodservant.com";
        expectedTailnet = "tailnet.woodservant.com";
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

      time.timeZone = "Europe/Berlin";

      nix = {
        enable = true;

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };

        optimise.automatic = true;
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      };

      nixpkgs.config.allowUnfree = true;

      boot = {
        kernelPackages = pkgs.linuxPackages_6_6;
        extraModprobeConfig = ''
          options btusb enable_autosuspend=n reset=1
        '';
      };

      programs.zsh.enable = true;

      hardware = {
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

      networking.networkmanager.enable = true;

      local.syncthing = {
        enable = true;
        guiUser = "alex";
        secrets = {
          password.name = "syncthing/password";
          cert.name = "syncthing/cert";
          key.name = "syncthing/key";
        };
        devices = {
          pixel7 = {
            id = "S6GEWYT-ST3KUYP-PBEE6WG-TYKMUL7-X6UQPX2-IQOL567-5YKKBQZ-VFO3WQV";
          };
          warden = {
            id = wardenSyncthingId;
          };
        };
        folders = {
          camera = {
            id = "v283i-tw1dt";
            label = "Camera";
            path = "/home/alexander/Pictures/Pixel7";
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

      security.pam.services = {
        ly = {
          fprintAuth = false;
          unixAuth = true;
          enableGnomeKeyring = lib.mkForce false;
        };
        login = {
          fprintAuth = false;
          unixAuth = true;
          enableGnomeKeyring = lib.mkForce false;
        };
        sudo.fprintAuth = false;
        "polkit-1" = {
          fprintAuth = false;
          unixAuth = true;
        };
      };

      services.blueman.enable = true;

      system.stateVersion = "24.05";
    };
}
