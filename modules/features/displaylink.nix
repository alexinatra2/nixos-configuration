{ self, inputs, ... }:
{
  flake.nixosModules.displaylink = { pkgs, ... }: {
    services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
    
    environment.variables = {
      KWIN_DRM_PREFER_COLOR_DEPTH = "24";
    };

    services = {
      desktopManager.plasma6 = {
        enable = true;
      };
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        defaultSession = "plasma";
      };

    };

    environment.systemPackages = with pkgs; [
      displaylink
    ];
  };
}
