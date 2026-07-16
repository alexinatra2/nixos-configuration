{ self, inputs, ... }:
{
  flake.nixosModules.displaylink =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.xserver.videoDrivers = lib.mkAfter [
        "displaylink"
        "modesetting"
      ];

      boot = {
        extraModulePackages = [ config.boot.kernelPackages.evdi ];
        kernelModules = [ "evdi" ];
      };

      environment.systemPackages = with pkgs; [
        displaylink
      ];

      systemd.services.displaylink-server = {
        description = "DisplayLink Manager Service";
        requires = [ "systemd-udevd.service" ];
        after = [ "systemd-udevd.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
          Restart = "on-failure";
          RestartSec = 5;
          User = "root";
          Group = "root";
        };
      };
    };
}
