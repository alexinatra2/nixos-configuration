{ ... }:
{
  flake.nixosModules.agentPreferences =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.local.agentPreferences = {
        identity = {
          text = lib.mkOption {
            type = lib.types.lines;
            default = builtins.readFile ./SOUL.md;
            description = "Harness-neutral agent identity and communication preferences.";
          };

          file = lib.mkOption {
            type = lib.types.path;
            readOnly = true;
            default = pkgs.writeText "agent-SOUL.md" config.local.agentPreferences.identity.text;
            description = "Generated agent identity file.";
          };
        };

        policy = {
          text = lib.mkOption {
            type = lib.types.lines;
            default = builtins.readFile ./policy.md;
            description = "Harness-neutral agent operating policy.";
          };

          file = lib.mkOption {
            type = lib.types.path;
            readOnly = true;
            default = pkgs.writeText "agent-policy.md" config.local.agentPreferences.policy.text;
            description = "Generated agent operating policy file.";
          };
        };

        skillDirectories = lib.mkOption {
          type = with lib.types; listOf path;
          default = [ ];
          description = "Immutable harness-neutral Agent Skills directories.";
        };
      };
    };
}
