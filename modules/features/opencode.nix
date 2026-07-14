{ self, inputs, ... }:
{
  flake.nixosModules.opencode =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.local.base.username;
      homeDirectory = config.local.base.homeDirectory;

      jsonFormat = pkgs.formats.json { };

      npx = lib.getExe' pkgs.nodejs "npx";

      defaultMcpServers = {
        everything = {
          type = "local";
          command = [
            npx
            "-y"
            "@modelcontextprotocol/server-everything@2026.7.4"
          ];
        };

        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
          headers = {
            CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
          };
        };

        nixos = {
          type = "local";
          command = [ (lib.getExe pkgs.mcp-nixos) ];
        };

        pdf-reader-mpc = {
          type = "local";
          command = [
            npx
            "-y"
            "@sylphx/pdf-reader-mcp@3.0.14"
          ];
        };

        playwright = {
          type = "local";
          command = [ (lib.getExe pkgs.playwright-mcp) ];
        };

        duckduckgo-search = {
          type = "local";
          command = [
            npx
            "-y"
            "duckduckgo-mcp-server@0.1.2"
          ];
        };

        slidev-mcp = {
          type = "local";
          command = [
            npx
            "-y"
            "slidev-mcp@0.3.2"
          ];
        };

        sequential-thinking = {
          type = "local";
          command = [ (lib.getExe pkgs.mcp-server-sequential-thinking) ];
        };

        google-maps-platform-code-assist = {
          type = "local";
          command = [
            npx
            "-y"
            "@googlemaps/code-assist-mcp@0.2.1"
          ];
        };

        overpass-mcp = {
          type = "local";
          command = [ (lib.getExe inputs.overpass-mcp.packages.${pkgs.stdenv.hostPlatform.system}.default) ];
        };
      };

      opencodeConfig = jsonFormat.generate "opencode.json" {
        "$schema" = "https://opencode.ai/config.json";
        autoupdate = false;
        mcp = defaultMcpServers;
      };
    in
    {
      options.local.opencode = {
        enable = lib.mkEnableOption "opencode";
      };

      config = lib.mkIf config.local.opencode.enable {
        users.users.${username}.packages = [ pkgs.opencode ];

        systemd.tmpfiles.rules = [
          "d ${homeDirectory}/.config/opencode 0755 ${username} users -"
          "L+ ${homeDirectory}/.config/opencode/opencode.json - - - - ${opencodeConfig}"
        ];
      };
    };
}
