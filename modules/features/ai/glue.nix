{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.local.opencode.enable {
    local.opencode.settings.instructions = lib.mkDefault (
      map toString [
        config.local.ai.preferences.identity.file
        config.local.ai.preferences.policy.file
      ]
    );

    local.opencode.settings.skills.paths = lib.mkDefault (
      map toString config.local.ai.preferences.skillDirectories
    );

    local.opencode.settings.mcp = lib.mkDefault (
      lib.mapAttrs (
        _: server:
        {
          type = server.transport;
          enabled = server.enable;
        }
        // lib.optionalAttrs (server.command != null) { command = server.command; }
        // lib.optionalAttrs (server.url != null) { url = server.url; }
        // lib.optionalAttrs (server.environment != { }) { environment = server.environment; }
        // lib.optionalAttrs (server.headers != { }) { headers = server.headers; }
        // lib.optionalAttrs (server.timeout != null) { timeout = server.timeout; }
      ) config.local.ai.mcp.servers
    );

    local.opencode.settings.agent.plan = lib.mkDefault {
      description = "Plan";
      permission = {
        edit = "deny";
        bash = "deny";
        plan_read = "allow";
        plan_write = "allow";
      };
    };

    local.opencode.settings.plugin = lib.mkDefault (
      config.local.opencode.bundledPlugins ++ [ "opencode-pty@0.3.6" ]
    );
  };
}
