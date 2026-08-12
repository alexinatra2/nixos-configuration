{ self, inputs, ... }:
{
  flake.nixosModules.llms =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      services.ollama = {
        enable = true;

        # Listen on all interfaces. Firewall below exposes it only via Nebula.
        host = "0.0.0.0";
        port = 11434;

        # Do not use openFirewall = true here, because that would open it globally.
        openFirewall = false;
      };

      networking.firewall = {
        enable = true;

        interfaces = {
          nebula0.allowedTCPPorts = [ 11434 ];
        };
      };
    };
}
