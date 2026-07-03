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
      cfg = config.local.opencode;
      username = config.local.base.username;
      homeDirectory = config.local.base.homeDirectory;

      jsonFormat = pkgs.formats.json { };

      packageWithExtraPackages =
        if cfg.extraPackages != [ ] then
          pkgs.symlinkJoin {
            inherit (cfg.package) meta;
            name = "${lib.getName cfg.package}-wrapped-${lib.getVersion cfg.package}";
            paths = [ cfg.package ];
            preferLocalBuild = true;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/opencode \
                --suffix PATH : ${lib.makeBinPath cfg.extraPackages}
            '';
          }
        else
          cfg.package;

      defaultMcpServers = {
        everything = {
          type = "local";
          command = [
            "npx"
            "-y"
            "@modelcontextprotocol/server-everything"
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
          command = [
            "nix"
            "run"
            "github:utensils/mcp-nixos"
            "--"
          ];
        };

        pdf-reader-mpc = {
          type = "local";
          command = [
            "npx"
            "@sylphx/pdf-reader-mcp"
          ];
        };

        playwright = {
          type = "local";
          command = [ (lib.getExe pkgs.playwright-mcp) ];
        };

        duckduckgo-search = {
          type = "local";
          command = [
            "npx"
            "-y"
            "duckduckgo-mcp-server"
          ];
        };

        slidev-mcp = {
          type = "local";
          command = [
            "npx"
            "-y"
            "slidev-mcp"
          ];
        };

        sequential-thinking = {
          type = "local";
          command = [
            "npx"
            "-y"
            "@modelcontextprotocol/server-sequential-thinking"
          ];
        };

        google-maps-platform-code-assist = {
          type = "local";
          command = [
            "npx"
            "-y"
            "@googlemaps/code-assist-mcp@latest"
          ];
        };

        overpass-mcp = {
          type = "local";
          command = [ (lib.getExe inputs.overpass-mcp.packages.${pkgs.stdenv.hostPlatform.system}.default) ];
        };
      };

      opencodeConfig = jsonFormat.generate "opencode.json" (
        {
          "$schema" = "https://opencode.ai/config.json";
          autoupdate = false;
        }
        // cfg.settings
        // {
          mcp = defaultMcpServers // (cfg.settings.mcp or { });
        }
      );
    in
    {
      options.local.opencode = {
        enable = lib.mkEnableOption "opencode";

        package = lib.mkPackageOption pkgs "opencode" { };

        extraPackages = lib.mkOption {
          type = with lib.types; listOf package;
          default = with pkgs; [
            bun
            fd
            gh
            git
            jq
            nodejs
          ];
          description = "Extra packages available to OpenCode and its MCP commands.";
        };

        settings = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
          description = "Additional OpenCode settings merged into ~/.config/opencode/opencode.json.";
        };
      };

      config = lib.mkIf cfg.enable {
        users.users.${username}.packages = [ packageWithExtraPackages ];

        systemd.tmpfiles.rules = [
          "d ${homeDirectory}/.config/opencode 0755 ${username} users -"
          "L+ ${homeDirectory}/.config/opencode/opencode.json - - - - ${opencodeConfig}"
        ];
      };
    };
}
