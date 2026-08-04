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

        # Listen on all interfaces. Firewall below exposes it only via Tailscale.
        host = "0.0.0.0";
        port = 11434;

        # Do not use openFirewall = true here, because that would open it globally.
        openFirewall = false;
      };

      networking.firewall = {
        enable = true;

        # Keep Tailscale available while Nebula is validated.
        interfaces = {
          tailscale0.allowedTCPPorts = [ 11434 ];
          nebula0.allowedTCPPorts = [ 11434 ];
        };
      };
    };
}
