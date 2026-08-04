{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.local.ai.preferences = {
    identity = {
      text = lib.mkOption {
        type = lib.types.lines;
        default = builtins.readFile ./SOUL.md;
        description = "Harness-neutral agent identity and communication preferences.";
      };

      file = lib.mkOption {
        type = lib.types.path;
        readOnly = true;
        default = pkgs.writeText "agent-SOUL.md" config.local.ai.preferences.identity.text;
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
        default = pkgs.writeText "agent-policy.md" config.local.ai.preferences.policy.text;
        description = "Generated agent operating policy file.";
      };
    };

    skillDirectories = lib.mkOption {
      type = with lib.types; listOf path;
      default = [ ./skills ];
      description = "Immutable harness-neutral Agent Skills directories.";
    };
  };
}
