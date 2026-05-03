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
      services.tailscale.enable = true;

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

        # Only allow Ollama through the Tailscale interface.
        interfaces."tailscale0".allowedTCPPorts = [ 11434 ];
      };
    };

  flake.modules.homeManager.llms =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        ollama
        python313Packages.huggingface-hub
      ];

      sops.secrets."llms/huggingface/token" = { };

      sops.templates."llms/huggingface/token-file" = {
        content = config.sops.placeholder."llms/huggingface/token";
        mode = "0400";
      };

      home.sessionVariables.HF_TOKEN_PATH = config.sops.templates."llms/huggingface/token-file".path;
    };
}
