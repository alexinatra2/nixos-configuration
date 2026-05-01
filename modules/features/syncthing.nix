{ self, inputs, ... }:
{
  flake.nixosModules.syncthing =
    { config, ... }:
    {
      sops.secrets = {
        "syncthing/password" = { };
        "syncthing/cert" = { };
        "syncthing/key" = { };
      };

      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
        guiPasswordFile = config.sops.secrets."syncthing/password".path;
        cert = config.sops.secrets."syncthing/cert".path;
        key = config.sops.secrets."syncthing/key".path;

        settings = {
          gui.user = "alex";
          devices = {
            pixel7 = {
              id = "S6GEWYT-ST3KUYP-PBEE6WG-TYKMUL7-X6UQPX2-IQOL567-5YKKBQZ-VFO3WQV";
            };
          };
        };
      };
    };
}
