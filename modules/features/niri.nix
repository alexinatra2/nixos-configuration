{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    { pkgs, lib, ... }:
    let
      niriPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    in
    {
      programs.niri = {
        enable = true;
        package = niriPackage;
      };

      services.displayManager.sessionPackages = [ niriPackage ];

      environment.systemPackages = with pkgs; [
        xwayland-satellite
      ];
    };

  perSystem =
    {
      system,
      lib,
      self',
      ...
    }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    if pkgs.stdenv.isLinux then
      {
        packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
          inherit pkgs;
          settings = {
            spawn-at-startup = [
              (lib.getExe self'.packages.myNoctalia)
            ];

            binds = {
              "Mod+Shift+Q".quit = { };

              "Mod+Left".focus-window-down-or-column-left = { };
              "Mod+Right".focus-window-up-or-column-right = { };
              "Mod+Up".focus-window-or-monitor-up = { };
              "Mod+Down".focus-window-or-monitor-down = { };

              "Mod+H".focus-window-down-or-column-left = { };
              "Mod+L".focus-window-up-or-column-right = { };
              "Mod+K".focus-window-or-monitor-up = { };
              "Mod+J".focus-window-or-monitor-down = { };

              "Mod+Shift+Left".move-window-to-monitor-left = { };
              "Mod+Shift+Right".move-window-to-monitor-right = { };
              "Mod+Shift+Up".move-window-to-workspace-up = { };
              "Mod+Shift+Down".move-window-to-workspace-down = { };

              "Mod+Shift+H".move-window-to-monitor-left = { };
              "Mod+Shift+L".move-window-to-monitor-right = { };
              "Mod+Shift+K".move-window-to-workspace-up = { };
              "Mod+Shift+J".move-window-to-workspace-down = { };

              "Mod+O".toggle-overview = { };

              "Mod+1"."focus-workspace" = "main";
              "Mod+2"."focus-workspace" = "dev";
              "Mod+3"."focus-workspace" = "web";

              "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
              "Mod+Q".close-window = { };
              "Mod+Space".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
            };
          };
        };
      }
    else
      { };
}
