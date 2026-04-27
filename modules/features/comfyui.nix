{ ... }:
{
  flake.modules.homeManager.comfyui =
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
    let
      cfg = config.services.comfyui;
      hasMcp = options ? programs.mcp;
      comfyuiStart = pkgs.writeShellScript "comfyui-start" ''
        set -euo pipefail

        data_dir="${cfg.dataDir}"

        mkdir -p "$data_dir"
        if [ ! -d "$data_dir/.git" ]; then
          rm -rf "$data_dir"
          ${pkgs.git}/bin/git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git "$data_dir"
        else
          ${pkgs.git}/bin/git -C "$data_dir" pull --ff-only || true
        fi

        if [ ! -d "$data_dir/.venv" ]; then
          ${pkgs.python3}/bin/python3 -m venv "$data_dir/.venv"
        fi

        "$data_dir/.venv/bin/pip" install --upgrade pip setuptools wheel
        "$data_dir/.venv/bin/pip" install -r "$data_dir/requirements.txt"

        exec "$data_dir/.venv/bin/python" "$data_dir/main.py" --listen ${cfg.host} --port ${toString cfg.port}
      '';
    in
    {
      options.services.comfyui = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = pkgs.stdenv.isLinux;
          description = "Whether to run a local ComfyUI service and MCP server integration.";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Host ComfyUI binds to.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 8188;
          description = "Port for the ComfyUI HTTP API.";
        };

        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "${config.xdg.dataHome}/comfyui";
          description = "Directory where ComfyUI source and venv are stored.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          git
          nodejs
          python3
        ];

        systemd.user.services.comfyui = lib.mkIf pkgs.stdenv.isLinux {
          Unit = {
            Description = "ComfyUI image generation server";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = "${comfyuiStart}";
            Restart = "on-failure";
            RestartSec = 5;
          };

          Install.WantedBy = [ "default.target" ];
        };

        programs.mcp = lib.mkIf hasMcp {
          servers.comfyui = {
            command = "npx";
            args = [
              "-y"
              "comfyui-mcp"
            ];
            env = {
              COMFYUI_HOST = cfg.host;
              COMFYUI_PORT = toString cfg.port;
              COMFYUI_PATH = cfg.dataDir;
            };
          };
        };
      };
    };
}
