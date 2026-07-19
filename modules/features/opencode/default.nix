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
      memoryDirectory = "${homeDirectory}/.local/share/opencode/memory";
      plansDirectory = "${homeDirectory}/.local/share/opencode/plans";
      planPlugin = pkgs.writeText "plan-store.ts" (builtins.readFile ./plugins/plan-store.ts);

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
        agent.plan = {
          description = "Plan";
          permission = {
            edit = "deny";
            bash = "deny";
            plan_read = "allow";
            plan_write = "allow";
          };
        };
        mcp = mcpServers;
        plugin = [
          "opencode-pty"
          "@slkiser/opencode-quota@3.11.2"
        ];
        skills.paths = [ (toString ./skills) ];
        references.memory.path = memoryDirectory;
        tool_output = {
          max_lines = 200;
          max_bytes = 8192;
        };
      };

      quotaConfig = jsonFormat.generate "quota-toast.json" {
        enabledProviders = [ "openai" ];
        formatStyle = "allWindows";
        percentDisplayMode = "remaining";
        enableToast = false;
        tuiSidebarPanel.enabled = false;
        tuiCompactStatus.enabled = false;
        maintainerAnnouncements.enabled = false;
      };

      tuiConfig = jsonFormat.generate "tui.json" {
        "$schema" = "https://opencode.ai/tui.json";
        theme = "stylix";
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
          "d ${homeDirectory}/.config/opencode/opencode-quota 0755 ${username} users -"
          "d ${homeDirectory}/.config/opencode/plugins 0755 ${username} users -"
          "d ${memoryDirectory} 0755 ${username} users -"
          "d ${memoryDirectory}/global 0755 ${username} users -"
          "d ${memoryDirectory}/workspaces 0755 ${username} users -"
          "d ${plansDirectory} 0755 ${username} users -"
          "r ${homeDirectory}/.config/opencode/opencode.jsonc"
          "r ${homeDirectory}/.config/opencode/tui.json.b"
          "L+ ${homeDirectory}/.config/opencode/opencode.json - - - - ${opencodeConfig}"
          "L+ ${homeDirectory}/.config/opencode/tui.json - - - - ${tuiConfig}"
          "L+ ${homeDirectory}/.config/opencode/opencode-quota/quota-toast.json - - - - ${quotaConfig}"
          "C+ ${homeDirectory}/.config/opencode/plugins/plan-store.ts - - - - ${planPlugin}"
        ];
      };
    };
}
