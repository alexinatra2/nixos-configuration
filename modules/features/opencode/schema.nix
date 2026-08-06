# Top-level `settings` option type mirroring opencode's config.json schema.
# Rendering to snake_case JSON lives in ./render.nix.
{ lib, pkgs }:

let
  types = import ./types.nix { inherit lib pkgs; };
  agents = import ./types-agents.nix {
    inherit lib pkgs;
    types = types;
  };

  settingsType = lib.types.submodule {
    options = {
      shell = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Shell used to run commands.";
      };

      logLevel = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "DEBUG"
            "INFO"
            "WARN"
            "ERROR"
          ]
        );
        default = null;
        description = "Log level. (opencode.json: `log_level`)";
      };

      server = lib.mkOption {
        type = lib.types.nullOr agents.serverType;
        default = null;
        description = "Settings for the local HTTP server.";
      };

      command = lib.mkOption {
        type = lib.types.attrsOf agents.commandType;
        default = { };
        description = "Custom commands.";
      };

      skills = lib.mkOption {
        type = lib.types.nullOr agents.skillsType;
        default = null;
        description = "Skill loading configuration.";
      };

      references = lib.mkOption {
        type = lib.types.attrsOf agents.referenceType;
        default = { };
        description = "Named git or local directory references.";
      };

      watcher = lib.mkOption {
        type = lib.types.nullOr agents.watcherType;
        default = null;
        description = "File watcher configuration.";
      };

      snapshot = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Enable or disable filesystem snapshot tracking.";
      };

      plugin = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.listOf (
            lib.types.oneOf [
              lib.types.str
              (lib.types.submodule {
                options = {
                  name = lib.mkOption {
                    type = lib.types.str;
                    description = "Plugin package name.";
                  };

                  options = lib.mkOption {
                    type = types.jsonType;
                    default = { };
                    description = "Plugin options.";
                  };
                };
              })
            ]
          )
        );
        default = null;
        description = "Plugins to load.";
      };

      share = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "manual"
            "auto"
            "disabled"
          ]
        );
        default = null;
        description = "Share and permission settings.";
      };

      autoupdate = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.oneOf [
            lib.types.bool
            (lib.types.enum [ "notify" ])
          ]
        );
        default = null;
        description = "Enable or notify about updates.";
      };

      disabledProviders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Providers to disable. (opencode.json: `disabled_providers`)";
      };

      enabledProviders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Providers to enable, restricting to these. (opencode.json: `enabled_providers`)";
      };

      model = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Default model id.";
      };

      smallModel = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model used for lightweight tasks. (opencode.json: `small_model`)";
      };

      defaultAgent = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Agent used by default. (opencode.json: `default_agent`)";
      };

      subagentDepth = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Maximum depth of nested subagents. (opencode.json: `subagent_depth`)";
      };

      username = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Username shown in the TUI.";
      };

      agent = lib.mkOption {
        type = lib.types.attrsOf agents.agentType;
        default = { };
        description = "Custom agents.";
      };

      provider = lib.mkOption {
        type = lib.types.attrsOf types.providerType;
        default = { };
        description = "Provider configuration and model overrides.";
      };

      mcp = lib.mkOption {
        type = lib.types.attrsOf agents.mcpServerType;
        default = { };
        description = "Named MCP servers (`local` or `remote`).";
      };

      formatter = lib.mkOption {
        type = lib.types.nullOr agents.formatterType;
        default = null;
        description = "Enable formatters, or per-language overrides.";
      };

      lsp = lib.mkOption {
        type = lib.types.nullOr agents.lspType;
        default = null;
        description = "Enable LSP servers, or per-language overrides.";
      };

      instructions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Instruction files or patterns to include in the system prompt.";
      };

      permission = lib.mkOption {
        type = lib.types.nullOr types.permissionType;
        default = null;
        description = "Permission rules.";
      };

      tools = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = { };
        description = "Per-tool enable/disable flags.";
      };

      attachment = lib.mkOption {
        type = lib.types.nullOr agents.attachmentType;
        default = null;
        description = "Attachment configuration.";
      };

      enterprise = lib.mkOption {
        type = lib.types.nullOr agents.enterpriseType;
        default = null;
        description = "Enterprise settings.";
      };

      toolOutput = lib.mkOption {
        type = lib.types.nullOr agents.toolOutputType;
        default = null;
        description = "Tool output limits. (opencode.json: `tool_output`)";
      };

      compaction = lib.mkOption {
        type = lib.types.nullOr agents.compactionType;
        default = null;
        description = "Transcript compaction settings.";
      };

      experimental = lib.mkOption {
        type = lib.types.nullOr agents.experimentalType;
        default = null;
        description = "Experimental settings.";
      };
    };
  };
in
{
  inherit
    settingsType
    types
    agents
    ;
}
