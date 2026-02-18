{
  flake.modules.homeManager.mcp =
    { config, lib, ... }:
    {
      options.mcp = {
        enable = lib.mkEnableOption "MCP";
      };

      config = lib.mkIf config.mcp.enable {
        programs.mcp.enable = true;
      };
    };
}
