{ ... }:
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

      mcpServers = {
        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
          enabled = true;
          headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        };

        nixos = {
          type = "local";
          command = [ (lib.getExe pkgs.mcp-nixos) ];
          enabled = false;
        };

        pdf-reader-mpc = {
          type = "local";
          command = [
            npx
            "-y"
            "@sylphx/pdf-reader-mcp@3.0.14"
          ];
          enabled = false;
        };

        playwright = {
          type = "local";
          command = [ (lib.getExe pkgs.playwright-mcp) ];
          enabled = false;
        };

        duckduckgo-search = {
          type = "local";
          command = [
            npx
            "-y"
            "duckduckgo-mcp-server@0.1.2"
          ];
          enabled = true;
        };

        slidev-mcp = {
          type = "local";
          command = [
            npx
            "-y"
            "slidev-mcp@0.3.2"
          ];
          enabled = false;
        };
      };

      opencodeConfig = jsonFormat.generate "opencode.json" {
        "$schema" = "https://opencode.ai/config.json";
        autoupdate = false;
        compaction.prune = true;
        instructions = [ (toString ./system-prompt.md) ];
        mcp = mcpServers;
        plugin = [ "opencode-pty" ];
        skills.paths = [ (toString ./skills) ];
        tool_output = {
          max_lines = 200;
          max_bytes = 8192;
        };
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
