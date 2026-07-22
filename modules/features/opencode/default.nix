{ inputs, ... }:
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
      goeranhCfg = config.local.opencode.goeranh;
      loreCfg = config.local.opencode.lore;
      lorePackage = inputs.lore.packages.${pkgs.stdenv.hostPlatform.system}.lore-mcp;
      opencodePlugins = pkgs.buildNpmPackage {
        pname = "opencode-plugins";
        version = "1.0.0";
        src = ./plugins;
        npmDepsHash = "sha256-s1DgYzKodzwevWRx4MDqAyxGEd7Et3wGyLXcHarC0fU=";
        nativeBuildInputs = [ pkgs.esbuild ];

        buildPhase = ''
          runHook preBuild
          esbuild plan-store.ts tmux-window-title.ts feature-worktree.ts --bundle --format=esm --platform=node --outdir=dist
          runHook postBuild
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
      }
      // lib.optionalAttrs loreCfg.enable {
        lore = {
          type = "local";
          command = [ "${lorePackage}/bin/lore-mcp" ];
          enabled = true;
          environment = {
            LORE_API_URL = loreCfg.endpoint;
            LORE_API_TOKEN_FILE = config.sops.secrets."lore/api-token".path;
          };
        };
      };

      opencodeConfig = jsonFormat.generate "opencode.json" (
        {
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
            "${opencodePlugins}/plan-store.js"
            "${opencodePlugins}/tmux-window-title.js"
            "${opencodePlugins}/feature-worktree.js"
            "opencode-pty@0.3.6"
            "@slkiser/opencode-quota@3.11.2"
          ];
          skills.paths = [ (toString ./skills) ];
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
      options.local.opencode = {
        enable = lib.mkEnableOption "opencode";

        goeranh = {
          enable = lib.mkEnableOption "Goeranh OpenCode provider";

          sopsFile = lib.mkOption {
            type = lib.types.path;
            description = "SOPS file containing the Goeranh API token.";
          };
        };

        lore = {
          enable = lib.mkEnableOption "Lore-backed OpenCode memory";

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

        worktreeRoot = lib.mkOption {
          type = lib.types.str;
          default = "${homeDirectory}/.local/share/opencode/worktrees";
          description = "Root directory for feature-development worktrees.";
        };
      };

      config = lib.mkIf config.local.opencode.enable {
        users.users.${username}.packages = [ pkgs.opencode ];

        environment.sessionVariables.OPENCODE_WORKTREE_ROOT = config.local.opencode.worktreeRoot;

        sops.secrets."opencode/goeranh-token" = lib.mkIf goeranhCfg.enable {
          inherit (goeranhCfg) sopsFile;
          owner = username;
          group = "users";
          mode = "0400";
        };

        sops.secrets."lore/api-token" = lib.mkIf loreCfg.enable {
          inherit (loreCfg) sopsFile;
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
    };
}
