{
  flake.modules.nixos.bootloader =
    { pkgs, ... }:
    {
      boot.loader = {
        systemd-boot.enable = false;
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

      swapDevices = [
        {
          device = "/var/lib/swapfile";
          size = 32 * 1024;
        }
      ];
    };
}
