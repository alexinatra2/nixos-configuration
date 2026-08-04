{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.ai.opencode;
  preferences = config.local.ai.preferences;
  username = config.local.base.username;
  homeDirectory = config.local.base.homeDirectory;
  memoryDirectory = "${homeDirectory}/.local/share/opencode/memory";
  plansDirectory = "${homeDirectory}/.local/share/opencode/plans";
  goeranhCfg = cfg.goeranh;
  opencodePlugins = pkgs.buildNpmPackage {
    pname = "opencode-plugins";
    version = "1.0.0";
    src = ./opencode/plugins;
    npmDepsHash = "sha256-s1DgYzKodzwevWRx4MDqAyxGEd7Et3wGyLXcHarC0fU=";
    nativeBuildInputs = [
      pkgs.esbuild
      pkgs.git
    ];

    buildPhase = ''
      runHook preBuild
      esbuild plan-store.ts tmux-window-title.ts feature-worktree.ts --bundle --format=esm --platform=node --outdir=dist
      runHook postBuild
    '';

    doCheck = true;
    checkPhase = ''
      runHook preCheck
      esbuild feature-worktree.test.ts plan-store.test.ts --bundle --format=esm --platform=node --outdir=dist/tests --out-extension:.js=.mjs
      node --test dist/tests/*.test.mjs
      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall
      install -Dm644 dist/plan-store.js "$out/plan-store.js"
      install -Dm644 dist/tmux-window-title.js "$out/tmux-window-title.js"
      install -Dm644 dist/feature-worktree.js "$out/feature-worktree.js"
      runHook postInstall
    '';
  };

  jsonFormat = pkgs.formats.json { };

  mcpServers = lib.mapAttrs (
    _: server:
    {
      type = server.transport;
      enabled = server.enable;
    }
    // lib.optionalAttrs (server.command != null) { inherit (server) command; }
    // lib.optionalAttrs (server.url != null) { inherit (server) url; }
    // lib.optionalAttrs (server.environment != { }) { inherit (server) environment; }
    // lib.optionalAttrs (server.headers != { }) { inherit (server) headers; }
    // lib.optionalAttrs (server.timeout != null) { inherit (server) timeout; }
  ) config.local.ai.mcp.servers;

  opencodeConfig = jsonFormat.generate "opencode.json" (
    {
      "$schema" = "https://opencode.ai/config.json";
      autoupdate = false;
      compaction.prune = true;
      instructions = [
        preferences.identity.file
        preferences.policy.file
      ];
      permission.external_directory."${cfg.worktreeRoot}/**" = "allow";
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
        "${opencodePlugins}/plan-store.js"
        "${opencodePlugins}/tmux-window-title.js"
        "${opencodePlugins}/feature-worktree.js"
        "opencode-pty@0.3.6"
        "@slkiser/opencode-quota@3.11.2"
      ];
      skills.paths = map toString preferences.skillDirectories;
      references.memory.path = memoryDirectory;
      tool_output = {
        max_lines = 200;
        max_bytes = 8192;
      };
    }
    // lib.optionalAttrs goeranhCfg.enable {
      provider.goeranh = {
        name = "Goeranh";
        npm = "@ai-sdk/openai-compatible";
        options = {
          baseURL = "https://ai.goeranh.de/v1";
          apiKey = "{file:${config.sops.secrets."opencode/goeranh-token".path}}";
        };
        models."deepreinforce-ai/Ornith-1.0-35B-GGUF:Q4_K_M" = {
          name = "Ornith 1.0 35B Q4_K_M";
          attachment = false;
          reasoning = true;
          tool_call = true;
          interleaved.field = "reasoning_content";
          modalities = {
            input = [ "text" ];
            output = [ "text" ];
          };
          limit = {
            context = 256000;
            output = 65536;
          };
        };
      };
    }
  );

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
  options.local.ai.opencode = {
    enable = lib.mkEnableOption "opencode";

    goeranh = {
      enable = lib.mkEnableOption "Goeranh OpenCode provider";

      sopsFile = lib.mkOption {
        type = lib.types.path;
        description = "SOPS file containing the Goeranh API token.";
      };
    };

    worktreeRoot = lib.mkOption {
      type = lib.types.str;
      default = "${homeDirectory}/.local/share/opencode/worktrees";
      description = "Root directory for feature-development worktrees.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${username}.packages = [ pkgs.opencode ];

    environment.sessionVariables.OPENCODE_WORKTREE_ROOT = cfg.worktreeRoot;

    sops.secrets."opencode/goeranh-token" = lib.mkIf goeranhCfg.enable {
      inherit (goeranhCfg) sopsFile;
      owner = username;
      group = "users";
      mode = "0400";
    };

    systemd.tmpfiles.rules = [
      "d ${homeDirectory}/.config/opencode 0755 ${username} users -"
      "d ${homeDirectory}/.config/opencode/opencode-quota 0755 ${username} users -"
      "d ${memoryDirectory} 0755 ${username} users -"
      "d ${memoryDirectory}/global 0755 ${username} users -"
      "d ${memoryDirectory}/workspaces 0755 ${username} users -"
      "d ${plansDirectory} 0755 ${username} users -"
      "r ${homeDirectory}/.config/opencode/opencode.jsonc"
      "r ${homeDirectory}/.config/opencode/plugins/plan-store.ts"
      "r ${homeDirectory}/.config/opencode/tui.json.b"
      "L+ ${homeDirectory}/.config/opencode/opencode.json - - - - ${opencodeConfig}"
      "L+ ${homeDirectory}/.config/opencode/tui.json - - - - ${tuiConfig}"
      "L+ ${homeDirectory}/.config/opencode/opencode-quota/quota-toast.json - - - - ${quotaConfig}"
    ];
  };
}
