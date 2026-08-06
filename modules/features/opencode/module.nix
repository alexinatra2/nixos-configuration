{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.opencode;
  username = config.local.base.username;
  homeDirectory = config.local.base.homeDirectory;
  plansDirectory = "${homeDirectory}/.local/share/opencode/plans";
  goeranhCfg = cfg.goeranh;

  schema = import ./schema.nix { inherit lib pkgs; };
  render = import ./render.nix { inherit lib; };
  tui = import ./tui.nix { inherit lib pkgs; };
  pluginPkg = import ./plugins.nix { inherit pkgs; };

  settingsFile = pkgs.writeText "opencode-config.json" (render.renderSettings cfg.settings);
  tuiFile = pkgs.writeText "opencode-tui.json" (tui.renderTui cfg.tui);

  configFile =
    pkgs.runCommand "opencode-config.json"
      {
        nativeBuildInputs = [ pkgs.check-jsonschema ];
      }
      ''
        check-jsonschema --schemafile ${./schemas/opencode.schema.json} ${settingsFile}
        cp ${settingsFile} $out
      '';

  defaultTmpfiles = {
    "${homeDirectory}/.config/opencode" = { };
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
      source = toString configFile;
    };
    "${homeDirectory}/.config/opencode/tui.json" = {
      type = "L+";
      source = toString tuiFile;
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
  options.local.opencode = {
    enable = lib.mkEnableOption "opencode";

    settings = lib.mkOption {
      type = schema.settingsType;
      default = { };
      description = "opencode configuration (https://opencode.ai/config.json).";
    };

    tui = lib.mkOption {
      type = tui.tuiType;
      default = {
        theme = "stylix";
      };
      description = "opencode TUI configuration (https://opencode.ai/tui.json).";
    };

    goeranh = {
      enable = lib.mkEnableOption "Goeranh OpenCode provider";

      sopsFile = lib.mkOption {
        type = lib.types.path;
        description = "SOPS file containing the Goeranh API token.";
      };

      temperature = lib.mkOption {
        type = lib.types.nullOr lib.types.float;
        default = null;
        description = "Temperature for Goeranh provider models (0.0-1.0).";
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

    bundledPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      default = [
        "${pluginPkg}/plan-store.js"
        "${pluginPkg}/tmux-window-title.js"
        "${pluginPkg}/feature-worktree.js"
        "${pluginPkg}/repository-clone.js"
      ];
      description = "Paths to plugins bundled with this module.";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = configFile;
      description = "Validated opencode config.json.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${username}.packages = [ pkgs.opencode ];

    environment.sessionVariables.OPENCODE_WORKTREE_ROOT = cfg.worktreeRoot;

    system.checks = [ configFile ];

    local.opencode.settings.autoupdate = lib.mkDefault false;
    local.opencode.settings.compaction.prune = lib.mkDefault true;
    local.opencode.settings.toolOutput = lib.mkDefault {
      maxLines = 200;
      maxBytes = 8192;
    };

    sops.secrets."opencode/goeranh-token" = lib.mkIf goeranhCfg.enable {
      inherit (goeranhCfg) sopsFile;
      owner = username;
      group = "users";
      mode = "0400";
    };

    local.opencode.settings.provider.goeranh = lib.mkIf goeranhCfg.enable {
      name = "Goeranh";
      npm = "@ai-sdk/openai-compatible";
      options = {
        baseURL = "https://ai.goeranh.de/v1";
        apiKey = "{file:${config.sops.secrets."opencode/goeranh-token".path}}";
        temperature = goeranhCfg.temperature;
      };
      models."deepreinforce-ai/Ornith-1.0-35B-GGUF:Q4_K_M" = {
        name = "Ornith 1.0 35B Q4_K_M";
        attachment = false;
        reasoning = true;
        toolCall = true;
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

    local.opencode.settings.permission.external_directory."${cfg.worktreeRoot}/**" = "allow";

    assertions = [
      {
        assertion =
          !goeranhCfg.enable
          || goeranhCfg.temperature == null
          || (goeranhCfg.temperature >= 0.0 && goeranhCfg.temperature <= 1.0);
        message = "opencode goeranh temperature must be between 0.0 and 1.0";
      }
      {
        assertion = lib.all (path: lib.hasPrefix "/" path) (lib.attrNames cfg.tmpfiles);
        message = "opencode tmpfiles keys must be absolute paths";
      }
      {
        assertion = lib.all (path: builtins.match "^[0-7]{3,4}$" cfg.tmpfiles.${path}.mode != null) (
          builtins.attrNames cfg.tmpfiles
        );
        message = "opencode tmpfiles modes must be valid octal permissions";
      }
      {
        assertion = lib.all (
          path:
          if
            cfg.tmpfiles.${path}.type == "l"
            || cfg.tmpfiles.${path}.type == "L"
            || cfg.tmpfiles.${path}.type == "L+"
          then
            cfg.tmpfiles.${path}.source != null
          else
            true
        ) (builtins.attrNames cfg.tmpfiles);
        message = "opencode tmpfiles symlink rules must have a source";
      }
      {
        assertion = lib.all (
          path:
          if
            cfg.tmpfiles.${path}.type != "l"
            && cfg.tmpfiles.${path}.type != "L"
            && cfg.tmpfiles.${path}.type != "L+"
          then
            cfg.tmpfiles.${path}.source == null
          else
            true
        ) (builtins.attrNames cfg.tmpfiles);
        message = "opencode tmpfiles non-symlink rules must not have a source";
      }
      {
        assertion = lib.all (
          path:
          if
            cfg.tmpfiles.${path}.type == "d"
            || cfg.tmpfiles.${path}.type == "D"
            || cfg.tmpfiles.${path}.type == "f"
            || cfg.tmpfiles.${path}.type == "F"
            || cfg.tmpfiles.${path}.type == "c"
            || cfg.tmpfiles.${path}.type == "C"
            || cfg.tmpfiles.${path}.type == "b"
            || cfg.tmpfiles.${path}.type == "B"
            || cfg.tmpfiles.${path}.type == "s"
            || cfg.tmpfiles.${path}.type == "S"
          then
            cfg.tmpfiles.${path}.owner != "" && cfg.tmpfiles.${path}.group != ""
          else
            true
        ) (builtins.attrNames cfg.tmpfiles);
        message = "opencode tmpfiles owning rules must specify owner and group";
      }
    ];

    systemd.tmpfiles.rules =
      let
        tmpfiles = cfg.tmpfiles;
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
      ) (builtins.attrNames tmpfiles);
  };
}
