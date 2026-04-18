{ self, inputs, ... }:
{
  flake.nixosModules.displaylink =
    { pkgs, ... }:
    {
      services.xserver.videoDrivers = [
        "displaylink"
        "modesetting"
      ];

      environment.systemPackages = with pkgs; [
        displaylink
      ];
    };
}
