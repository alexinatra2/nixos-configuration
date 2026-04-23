{ self, inputs, ... }:
{
  flake.modules.homeManager.ssh =
    {
      config,
      lib,
      ...
    }:
    let
      homelabHosts = [
        "proxmox"
        "openclaw"
      ];

      mkHostTemplate = host: {
        "ssh/matchblocks/${host}" = {
          content = ''
            Host ${host}
              HostName ${config.sops.placeholder."homelab/${host}/ip"}
              User ${config.sops.placeholder."homelab/${host}/user"}
          '';
          mode = "0600";
        };
      };

      mkHostSecrets = host: {
        "homelab/${host}/ip" = { };
        "homelab/${host}/user" = { };
      };
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
          "*" = {
            identitiesOnly = true;
            identityFile = [ "~/.ssh/id_ed25519" ];
          };
        };

        includes = map (host: config.sops.templates."ssh/matchblocks/${host}".path) homelabHosts;
      };

      sops.templates = lib.foldl' lib.recursiveUpdate { } (map mkHostTemplate homelabHosts);

      sops.secrets = lib.foldl' lib.recursiveUpdate { } (map mkHostSecrets homelabHosts);
    };
}
