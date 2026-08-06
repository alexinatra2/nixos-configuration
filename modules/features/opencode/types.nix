# Core type primitives for opencode's config schema (https://opencode.ai/config.json).
{ lib, pkgs }:

let
  jsonType = (pkgs.formats.json { }).type;
in
rec {
  inherit jsonType;

  # Submodule accepting the listed typed options plus arbitrary JSON-able keys.
  # Used for provider/agent/model `options` and LSP `initialization`, which are
  # free-form objects in the opencode schema.
  freeform =
    options:
    lib.types.submodule {
      inherit options;
      freeformType = jsonType;
    };

  actionType = lib.types.enum [
    "ask"
    "allow"
    "deny"
  ];

  permissionRuleType = lib.types.oneOf [
    actionType
    (lib.types.attrsOf actionType)
  ];

  # Either a bare action (e.g. deny everything) or an object mapping tool names
  # to rules. Per-tool rules merge across modules; a global default action is
  # expressed with the "*" key.
  permissionType = lib.types.oneOf [
    actionType
    (lib.types.attrsOf permissionRuleType)
  ];

  # Positive integer, or literal `false` (disable the timeout).
  intOrFalse = lib.types.oneOf [
    lib.types.ints.positive
    (lib.types.enum [ false ])
  ];

  modelType = lib.types.submodule {
    options = {
      id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model identifier.";
      };

      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Human-readable model name.";
      };

      family = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model family name.";
      };

      releaseDate = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model release date. (opencode.json: `release_date`)";
      };

      attachment = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether the model supports attachments.";
      };

      reasoning = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether the model supports reasoning.";
      };

      temperature = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether the model supports temperature.";
      };

      toolCall = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether the model supports tool calls. (opencode.json: `tool_call`)";
      };

      interleaved = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.oneOf [
            lib.types.bool
            lib.types.str
            (lib.types.submodule {
              options.field = lib.mkOption {
                type = lib.types.str;
                description = "Reasoning field name.";
              };
            })
          ]
        );
        default = null;
        description = "How reasoning content is interleaved in the response.";
      };

      cost = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              input = lib.mkOption {
                type = lib.types.float;
                description = "Cost per input token (USD).";
              };

              output = lib.mkOption {
                type = lib.types.float;
                description = "Cost per output token (USD).";
              };

              cacheRead = lib.mkOption {
                type = lib.types.nullOr lib.types.float;
                default = null;
                description = "Cost per cached input token. (opencode.json: `cache_read`)";
              };

              cacheWrite = lib.mkOption {
                type = lib.types.nullOr lib.types.float;
                default = null;
                description = "Cost per cache write token. (opencode.json: `cache_write`)";
              };

              contextOver200k = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.submodule {
                    options = {
                      input = lib.mkOption {
                        type = lib.types.float;
                        description = "Input cost over 200k context.";
                      };
                      output = lib.mkOption {
                        type = lib.types.float;
                        description = "Output cost over 200k context.";
                      };
                      cacheRead = lib.mkOption {
                        type = lib.types.nullOr lib.types.float;
                        default = null;
                        description = "Cached input cost over 200k context.";
                      };
                      cacheWrite = lib.mkOption {
                        type = lib.types.nullOr lib.types.float;
                        default = null;
                        description = "Cache write cost over 200k context.";
                      };
                    };
                  }
                );
                default = null;
                description = "Costs for context beyond 200k tokens. (opencode.json: `context_over_200k`)";
              };
            };
          }
        );
        default = null;
        description = "Pricing per token.";
      };

      limit = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              context = lib.mkOption {
                type = lib.types.ints.positive;
                description = "Maximum context window in tokens.";
              };

              output = lib.mkOption {
                type = lib.types.ints.positive;
                description = "Maximum output tokens.";
              };

              input = lib.mkOption {
                type = lib.types.nullOr lib.types.ints.positive;
                default = null;
                description = "Maximum input tokens.";
              };
            };
          }
        );
        default = null;
        description = "Token limits.";
      };

      modalities = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              input = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.enum [
                    "text"
                    "audio"
                    "image"
                    "video"
                    "pdf"
                  ]
                );
                default = [ ];
                description = "Supported input modalities.";
              };

              output = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.enum [
                    "text"
                    "audio"
                    "image"
                    "video"
                    "pdf"
                  ]
                );
                default = [ ];
                description = "Supported output modalities.";
              };
            };
          }
        );
        default = null;
        description = "Supported input/output modalities.";
      };

      experimental = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Mark as experimental.";
      };

      status = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "alpha"
            "beta"
            "deprecated"
            "active"
          ]
        );
        default = null;
        description = "Model status.";
      };

      provider = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              npm = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Provider npm package.";
              };

              api = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Provider API package.";
              };
            };
          }
        );
        default = null;
        description = "Provider implementation overrides for this model.";
      };

      options = lib.mkOption {
        type = freeform { };
        default = { };
        description = "Provider-specific model options.";
      };

      headers = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "HTTP headers for this model.";
      };

      variants = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.disabled = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Disable this variant for the model.";
            };
          }
        );
        default = { };
        description = "Variant-specific configuration.";
      };
    };
  };

  providerType = lib.types.submodule {
    options = {
      api = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Provider API identifier.";
      };

      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Human-readable provider name.";
      };

      env = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Environment variables used for provider credentials.";
      };

      id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Provider identifier.";
      };

      npm = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Provider npm package.";
      };

      whitelist = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Provider whitelist.";
      };

      blacklist = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Provider blacklist.";
      };

      options = lib.mkOption {
        type = freeform {
          apiKey = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Provider API key, e.g. `{env:VAR}` or `{file:path}`.";
          };

          baseURL = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Base URL for the provider API.";
          };

          enterpriseUrl = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "GitHub Enterprise URL for copilot authentication.";
          };

          setCacheKey = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Always set a prompt cache key for this provider.";
          };

          timeout = lib.mkOption {
            type = lib.types.nullOr intOrFalse;
            default = null;
            description = "Request timeout in ms, or false to disable.";
          };

          headerTimeout = lib.mkOption {
            type = lib.types.nullOr intOrFalse;
            default = null;
            description = "Response header timeout in ms, or false to disable.";
          };

          chunkTimeout = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.positive;
            default = null;
            description = "Timeout in ms between streamed chunks.";
          };
        };
        default = { };
        description = "Provider options (typed subset plus free-form extras).";
      };

      models = lib.mkOption {
        type = lib.types.attrsOf modelType;
        default = { };
        description = "Model overrides keyed by model id.";
      };
    };
  };
}
