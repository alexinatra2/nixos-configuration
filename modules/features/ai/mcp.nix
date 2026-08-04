{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.ai.mcp;
  username = config.local.base.username;
  npx = lib.getExe' pkgs.nodejs "npx";
  lorePackage = inputs.lore.packages.${pkgs.stdenv.hostPlatform.system}.lore-mcp;

  serverType = lib.types.submodule {
    options = {
      transport = lib.mkOption {
        type = lib.types.enum [
          "local"
          "remote"
        ];
        description = "MCP server transport.";
      };

      enable = lib.mkEnableOption "this MCP server";

      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command used to start a local MCP server.";
      };

      url = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "URL of a remote MCP server.";
      };

      environment = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = { };
        description = "Environment variables passed to a local MCP server.";
      };

      headers = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = { };
        description = "Headers sent to a remote MCP server.";
      };

      timeout = lib.mkOption {
        type = with lib.types; nullOr ints.positive;
        default = null;
        description = "Optional MCP connection timeout in milliseconds.";
      };
    };
  };
in
{
  options.local.ai.mcp = {
    servers = lib.mkOption {
      type = with lib.types; attrsOf serverType;
      default = {
        context7 = {
          transport = "remote";
          enable = true;
          url = "https://mcp.context7.com/mcp";
          headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        };

        nixos = {
          transport = "local";
          command = [ (lib.getExe pkgs.mcp-nixos) ];
        };

        pdf-reader-mpc = {
          transport = "local";
          command = [
            npx
            "-y"
            "@sylphx/pdf-reader-mcp@3.0.14"
          ];
        };

        playwright = {
          transport = "local";
          command = [ (lib.getExe pkgs.playwright-mcp) ];
        };

        duckduckgo-search = {
          transport = "local";
          enable = true;
          command = [
            npx
            "-y"
            "duckduckgo-mcp-server@0.1.2"
          ];
        };

        slidev-mcp = {
          transport = "local";
          command = [
            npx
            "-y"
            "slidev-mcp@0.3.2"
          ];
        };
      };
      description = "Harness-neutral MCP server catalog.";
    };

    lore = {
      enable = lib.mkEnableOption "Lore MCP server";

      endpoint = lib.mkOption {
        type = lib.types.str;
        default = "http://woodservant-prod.tailnet.woodservant.com";
        description = "Private Lore API endpoint.";
      };

      sopsFile = lib.mkOption {
        type = lib.types.path;
        description = "SOPS file containing the Lore API token.";
      };
    };
  };

  config = lib.mkMerge [
    {
      assertions = lib.mapAttrsToList (name: server: {
        assertion =
          if server.transport == "local" then
            server.command != null && server.url == null && server.headers == { }
          else
            server.url != null && server.command == null && server.environment == { };
        message = "local.ai.mcp.servers.${name} has fields incompatible with its transport.";
      }) cfg.servers;
    }

    (lib.mkIf cfg.lore.enable {
      local.ai.mcp.servers.lore = {
        transport = "local";
        enable = true;
        command = [ "${lorePackage}/bin/lore-mcp" ];
        environment = {
          LORE_API_URL = cfg.lore.endpoint;
          LORE_API_TOKEN_FILE = config.sops.secrets."lore/api-token".path;
        };
      };

      sops.secrets."lore/api-token" = {
        inherit (cfg.lore) sopsFile;
        owner = username;
        group = "users";
        mode = "0400";
      };
    })
  ];
}
