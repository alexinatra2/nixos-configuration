{ inputs, ... }:
let
  mkOpenCodeAgent = inputs.tentaflake.lib.x86_64-linux.mkOpenCodeAgent;
in
{
  imports = [
    inputs.tentaflake.nixosModules.default

    (mkOpenCodeAgent {
      name = "cthulhu";
      hostPort = 4096;
    })
  ];

  virtualisation.oci-containers.backend = "docker";

  # Reuse local NixOS policy and enable only TentaFlake's agent runtime.
  tentaflake = {
    auditd.enable = false;
    boot.enable = false;
    hardening.enable = false;
    locale.enable = false;
    networking.enable = false;
    nixSettings.enable = false;
    packages.enable = false;
    shell.enable = false;
    tailscale.enable = false;
    users.enable = false;
  };
}
