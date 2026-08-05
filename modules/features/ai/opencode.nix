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

  defaultTmpfiles = {
    "${homeDirectory}/.config/opencode" = { };
    "${homeDirectory}/.config/opencode/opencode-quota" = { };
    "${memoryDirectory}" = { };
    "${memoryDirectory}/global" = { };
    "${memoryDirectory}/workspaces" = { };
    "${plansDirectory}" = { };
    "${homeDirectory}/.config/opencode/opencode.jsonc" = {
      type = "r";
    };
    "${homeDirectory}/.config/opencode/plugins/plan-store.ts" = {
      type = "r";
    };
    "${homeDirectory}/.config/opencode/tui.json.b" = {
      type = "r";
    };
    "${homeDirectory}/.config/opencode/opencode.json" = {
      type = "L+";
      source = toString opencodeConfig;
    };
    "${homeDirectory}/.config/opencode/tui.json" = {
      type = "L+";
      source = toString tuiConfig;
    };
    "${homeDirectory}/.config/opencode/opencode-quota/quota-toast.json" = {
      type = "L+";
      source = toString quotaConfig;
    };
  };

  tmpfilesRuleType = lib.types.enum [
    "d"
    "D"
    "f"
    "F"
    "e"
    "E"
    "w"
    "W"
    "c"
    "C"
    "b"
    "B"
    "s"
    "S"
    "l"
    "L"
    "L+"
    "r"
    "x"
    "X"
    "a"
    "A"
  ];

  tmpfilesRule = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = tmpfilesRuleType;
        default = "d";
        description = "Type of tmpfiles rule (d=directory, f=file, L+=symlink, r=regular-file, etc).";
      };
      mode = lib.mkOption {
        type = lib.types.str;
        default = "0755";
        description = "Octal permission mode.";
      };
      owner = lib.mkOption {
        type = lib.types.str;
        default = username;
        description = "Owner of the created path.";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "users";
        description = "Group of the created path.";
      };
      age = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Age expression for periodic cleanup rules.";
      };
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Source path for symlink (L/L+/s/S) rules.";
      };
    };
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

    tmpfiles = lib.mkOption {
      type = lib.types.attrsOf tmpfilesRule;
      default = defaultTmpfiles;
      description = "systemd tmpfiles rules for opencode, keyed by absolute path.";
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

    assertions = [
      {
        assertion = lib.all (path: lib.hasPrefix "/" path) (lib.attrNames cfg.tmpfiles);
        message = "opencode tmpfiles keys must be absolute paths";
      }
      {
        assertion = lib.all (
          path:
          let
            mode = lib.attrByPath [ "mode" ] null cfg.tmpfiles.${path};
          in
          mode != null && builtins.match "^[0-7]{3,4}$" mode != null
        ) (lib.attrNames cfg.tmpfiles);
        message = "opencode tmpfiles modes must be valid octal permissions";
      }
      {
        assertion = lib.all (
          path:
          let
            r = cfg.tmpfiles.${path};
            t = lib.attrByPath [ "type" ] "d" r;
            source = lib.attrByPath [ "source" ] null r;
            isSymlink = t == "l" || t == "L" || t == "L+";
          in
          if isSymlink then source != null else source == null
        ) (lib.attrNames cfg.tmpfiles);
        message = "opencode tmpfiles symlink rules must have a source and non-symlinks must not";
      }
      {
        assertion = lib.all (
          path:
          let
            r = cfg.tmpfiles.${path};
            t = lib.attrByPath [ "type" ] "d" r;
            isOwning =
              t == "d"
              || t == "D"
              || t == "f"
              || t == "F"
              || t == "c"
              || t == "C"
              || t == "b"
              || t == "B"
              || t == "s"
              || t == "S";
            owner = lib.attrByPath [ "owner" ] null r;
            group = lib.attrByPath [ "group" ] null r;
          in
          if isOwning then owner != null && owner != "" && group != null && group != "" else true
        ) (lib.attrNames cfg.tmpfiles);
        message = "opencode tmpfiles owning rules must specify non-empty owner and group";
      }
    ];

    systemd.tmpfiles.rules = let
      tmpfiles = config.local.ai.opencode.tmpfiles;
    in
    lib.concatMap (
      path:
      let
        r = tmpfiles.${path};
        t = lib.attrByPath [ "type" ] "d" r;
        mode = lib.attrByPath [ "mode" ] "0755" r;
        owner = lib.attrByPath [ "owner" ] username r;
        group = lib.attrByPath [ "group" ] "users" r;
        age = lib.attrByPath [ "age" ] null r;
        source = lib.attrByPath [ "source" ] "" r;
      in
      [
        (
          if t == "r" || t == "e" || t == "E" || t == "x" || t == "X" then
            "${t} ${path}"
          else if t == "l" || t == "L" || t == "L+" then
            "${t} ${path} - - - - ${source}"
          else if age != null then
            "${t} ${path} ${mode} ${owner} ${group} ${age}"
          else
            "${t} ${path} ${mode} ${owner} ${group} -"
        )
      ]
    ) (lib.attrNames tmpfiles);
  };
}
