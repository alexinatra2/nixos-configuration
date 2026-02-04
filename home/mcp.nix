{ config, lib, ... }:
let
  cfg = config.mcp;
in
{
  options.mcp = {
    enable = lib.mkEnableOption "MCP";
  };

  config = lib.mkIf cfg.enable {
    programs.mcp = {
      enable = true;

      servers = {
        playwright = {
          command = "npx";
          args = [
            "-y"
            "@modelcontextprotocol/server-playwright"
          ];
        };
      };
    };
  };
}
