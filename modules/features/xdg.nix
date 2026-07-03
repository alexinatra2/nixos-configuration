{ ... }:
{
  flake.nixosModules.xdg =
    {
      lib,
      pkgs,
      ...
    }:
    let
      xdgOpen = pkgs.writeShellApplication {
        name = "xdg-open";
        runtimeInputs = [ pkgs.handlr ];
        text = ''
          exec ${lib.getExe pkgs.handlr} open "$@"
        '';
      };
    in
    {
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
        config = {
          niri = {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          };
          common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          };
        };
        xdgOpenUsePortal = false;
      };

      xdg.mime.defaultApplications = {
        "application/pdf" = "firefox.desktop";
        "image/*" = "imv.desktop";
        "video/*" = "mpv.desktop";
        "audio/*" = "mpv.desktop";
        "inode/directory" = "thunar.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "x-scheme-handler/terminal" = "kitty.desktop";
      };

      environment.sessionVariables.BROWSER = lib.getExe pkgs.firefox;

      environment.systemPackages = [
        pkgs.desktop-file-utils
        pkgs.firefox
        pkgs.handlr
        pkgs.imv
        pkgs.kitty
        pkgs.mpv
        pkgs.shared-mime-info
        pkgs.thunderbird
        pkgs.thunar
        pkgs.xdg-utils
        pkgs.zathura
        (lib.hiPrio xdgOpen)
      ];
    };
}
