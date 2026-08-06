# Remaining submodule types for opencode's config schema, split from
# ./types.nix to keep each file focused. Depends on `types` (core primitives).
{
  lib,
  pkgs,
  types,
}:

let
  jsonType = types.jsonType;
  freeform = types.freeform;

  gitReferenceType = lib.types.submodule {
    options.repository = lib.mkOption {
      type = lib.types.str;
      description = "Git repository URL.";
    };
  };

  localReferenceType = lib.types.submodule {
    options.path = lib.mkOption {
      type = lib.types.str;
      description = "Path to the reference (relative to the project root).";
    };
  };

  formatterServerType = lib.types.submodule {
    options = {
      disabled = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Disable formatting for this language.";
      };

      command = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Formatter command and arguments.";
      };

      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Environment variables for the formatter.";
      };

      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "File extensions the formatter applies to.";
      };
    };
  };

  lspServerType = lib.types.submodule {
    options = {
      disabled = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Disable the LSP server for this language.";
      };

      command = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "LSP server command and arguments.";
      };

      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "File extensions the LSP server applies to.";
      };

      env = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Environment variables for the LSP server.";
      };

      initialization = lib.mkOption {
        type = freeform { };
        default = { };
        description = "Initialization options sent to the LSP server.";
      };
    };
  };

  mcpOAuthType = lib.types.submodule {
    options = {
      clientId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "OAuth client id. (opencode.json: `client_id`)";
      };

      clientSecret = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "OAuth client secret, if required. (opencode.json: `client_secret`)";
      };

      scope = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "OAuth scopes to request.";
      };

      callbackPort = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.port;
        default = null;
        description = "Port for the local OAuth callback server. (opencode.json: `callback_port`)";
      };

      redirectUri = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "OAuth redirect URI. (opencode.json: `redirect_uri`)";
      };
    };
  };

  mcpLocalType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [ "local" ];
        default = "local";
        internal = true;
        description = "MCP server type.";
      };

      command = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Command and arguments to run the MCP server.";
      };

      cwd = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Working directory for the server process.";
      };

      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Environment variables for the server process.";
      };

      enabled = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Enable the MCP server on startup.";
      };

      timeout = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Request timeout in ms.";
      };
    };
  };

  mcpRemoteType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [ "remote" ];
        default = "remote";
        internal = true;
        description = "MCP server type.";
      };

      url = lib.mkOption {
        type = lib.types.str;
        description = "URL of the remote MCP server.";
      };

      enabled = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Enable the MCP server on startup.";
      };

      headers = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Headers to send with requests.";
      };

      oauth = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.oneOf [
            mcpOAuthType
            (lib.types.enum [ false ])
          ]
        );
        default = null;
        description = "OAuth configuration, or false to disable auto-detection.";
      };

      timeout = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Request timeout in ms.";
      };
    };
  };
  mcpServerType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [
          "local"
          "remote"
        ];
        default = "local";
        description = "MCP server type. Schema validation enforces the required fields.";
      };

      command = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Command and arguments to run a local MCP server.";
      };

      cwd = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Working directory for a local MCP server.";
      };

      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Environment variables for a local MCP server.";
      };

      enabled = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Enable or disable the MCP server on startup.";
      };

      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "URL of a remote MCP server.";
      };

      headers = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Headers to send with requests to a remote MCP server.";
      };

      oauth = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.oneOf [
            mcpOAuthType
            (lib.types.enum [ false ])
          ]
        );
        default = null;
        description = "OAuth configuration, or false to disable auto-detection.";
      };

      timeout = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Request timeout in ms.";
      };
    };
  };
in
rec {
  agentType = lib.types.submodule {
    options = {
      model = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model id this agent uses, or null for the default model.";
      };

      variant = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model variant for this agent.";
      };

      temperature = lib.mkOption {
        type = lib.types.nullOr lib.types.number;
        default = null;
        description = "Sampling temperature.";
      };

      topP = lib.mkOption {
        type = lib.types.nullOr lib.types.number;
        default = null;
        description = "Nucleus sampling threshold. (opencode.json: `top_p`)";
      };

      prompt = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "System prompt for this agent.";
      };

      disable = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Disable this agent.";
      };

      description = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Short description shown to other agents when delegating.";
      };

      mode = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "all"
            "primary"
            "subagent"
          ]
        );
        default = null;
        description = "Restrict where the agent can be used.";
      };

      hidden = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Hide from the agent list.";
      };

      options = lib.mkOption {
        type = freeform { };
        default = { };
        description = "Provider-specific options for this agent's model.";
      };

      color = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Hex color code or theme color (e.g. `primary`).";
      };

      steps = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Maximum number of steps before the agent hands back to the user.";
      };

      permission = lib.mkOption {
        type = types.permissionType;
        default = { };
        description = "Permission rules scoped to this agent.";
      };
    };
  };

  commandType = lib.types.submodule {
    options = {
      template = lib.mkOption {
        type = lib.types.str;
        description = "The command to run.";
      };

      description = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Description shown when listing commands.";
      };

      agent = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Agent to run the command with.";
      };

      model = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model to run the command with.";
      };

      variant = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model variant for the command.";
      };

      subtask = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Run as a subtask of the current session.";
      };
    };
  };

  serverType = lib.types.submodule {
    options = {
      port = lib.mkOption {
        type = lib.types.ints.port;
        description = "Port for the local HTTP server.";
      };

      hostname = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Hostname to bind the HTTP server to.";
      };

      mdns = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Advertise the server via mDNS.";
      };

      mdnsDomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Custom mDNS domain. (opencode.json: `mdns_domain`)";
      };

      cors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional domains to allow for CORS.";
      };
    };
  };

  inherit
    gitReferenceType
    localReferenceType
    ;

  referenceType = lib.types.oneOf [
    lib.types.str
    gitReferenceType
    localReferenceType
  ];

  skillsType = lib.types.submodule {
    options = {
      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Directories to load skills from.";
      };

      urls = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "URLs to load skills from.";
      };
    };
  };

  watcherType = lib.types.submodule {
    options.ignore = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Glob patterns to ignore when watching files.";
    };
  };

  inherit formatterServerType;

  formatterType = lib.types.oneOf [
    lib.types.bool
    (lib.types.attrsOf formatterServerType)
  ];

  inherit lspServerType;

  lspType = lib.types.oneOf [
    lib.types.bool
    (lib.types.attrsOf lspServerType)
  ];

  inherit mcpOAuthType;

  inherit mcpServerType;

  attachmentImageType = lib.types.submodule {
    options = {
      autoResize = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Automatically resize images before sending. (opencode.json: `auto_resize`)";
      };

      maxWidth = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Maximum image width in pixels. (opencode.json: `max_width`)";
      };

      maxHeight = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Maximum image height in pixels. (opencode.json: `max_height`)";
      };

      maxBase64Bytes = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Maximum base64 size of an image. (opencode.json: `max_base64_bytes`)";
      };
    };
  };

  attachmentType = lib.types.submodule {
    options.image = lib.mkOption {
      type = lib.types.nullOr attachmentImageType;
      default = null;
      description = "Image attachment settings.";
    };
  };

  toolOutputType = lib.types.submodule {
    options = {
      maxLines = lib.mkOption {
        type = lib.types.ints.positive;
        default = 2000;
        description = "Maximum lines of tool output before truncation. (opencode.json: `max_lines`)";
      };

      maxBytes = lib.mkOption {
        type = lib.types.ints.positive;
        default = 51200;
        description = "Maximum bytes of tool output before truncation. (opencode.json: `max_bytes`)";
      };
    };
  };

  compactionType = lib.types.submodule {
    options.prune = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Prune older messages from the transcript after compaction.";
    };
  };

  policyType = lib.types.submodule {
    options = {
      action = lib.mkOption {
        type = lib.types.enum [ "provider.use" ];
        description = "Action the policy applies to.";
      };

      effect = lib.mkOption {
        type = lib.types.enum [
          "allow"
          "deny"
        ];
        description = "Effect of the policy.";
      };

      resource = lib.mkOption {
        type = lib.types.str;
        description = "Resource the policy matches.";
      };
    };
  };

  experimentalType = lib.types.submodule {
    options.policies = lib.mkOption {
      type = lib.types.listOf policyType;
      default = [ ];
      description = "Experimental provider policies.";
    };
  };

  enterpriseType = lib.types.submodule {
    options = {
      bcdr = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Basic & Common Data Retrieval.";
      };

      bcdrRetentionDays = lib.mkOption {
        type = lib.types.ints.positive;
        default = 30;
        description = "BCDR retention period in days. (opencode.json: `bcdr_retention_days`)";
      };

      auditLogs = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable audit logs. (opencode.json: `audit_logs`)";
      };

      restrictedResponses = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable restricted responses. (opencode.json: `restricted_responses`)";
      };

      restrictedComplianceLogs = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable restricted compliance logs. (opencode.json: `restricted_compliance_logs`)";
      };
    };
  };
}
