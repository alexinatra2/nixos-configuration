{ self, ... }:
{
  flake = {
    nixosModules.tmuxRemote =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.local.tmuxRemote;
      shellToolset = lib.attrByPath [ "local" "shell" "toolset" ] null config;

      sshTmux = pkgs.writeShellApplication {
        name = "ssh-tmux";
        runtimeInputs = with pkgs; [
          coreutils
          fzf
          gawk
          openssh
        ];
        text = ''
          set -euo pipefail

          remote_tmux_command='tmux attach -t main || tmux new -s main'
          system_ssh_config=/etc/ssh/ssh_config
          user_ssh_config="$HOME/.ssh/config"
          config_files=()

          if [[ -f "$system_ssh_config" ]]; then
            config_files+=("$system_ssh_config")
          fi

          if [[ -f "$user_ssh_config" ]]; then
            config_files+=("$user_ssh_config")
          fi

          if (( ''${#config_files[@]} == 0 )); then
            printf 'ssh-tmux: no SSH config found in %s or %s\n' "$system_ssh_config" "$user_ssh_config" >&2
            exit 1
          fi

          pick_host() {
            local available_hosts
            local selected_host

            available_hosts="$(${pkgs.gawk}/bin/awk '
              BEGIN { IGNORECASE = 1 }
              /^[[:space:]]*Host[[:space:]]+/ {
                for (i = 2; i <= NF; i++) {
                  host = $i
                  if (host ~ /[*?]/) {
                    continue
                  }
                  if (host ~ /^!/) {
                    continue
                  }
                  print host
                }
              }
            ' "''${config_files[@]}" | sort -u)"

            if [[ -z "$available_hosts" ]]; then
              printf 'ssh-tmux: no concrete SSH hosts found in %s\n' "''${config_files[*]}" >&2
              exit 1
            fi

            selected_host="$(printf '%s\n' "$available_hosts" | ${pkgs.fzf}/bin/fzf --prompt='SSH host> ' --height=40%)" || exit 0

            if [[ -z "$selected_host" ]]; then
              exit 0
            fi

            printf '%s\n' "$selected_host"
          }

          host=""
          ssh_args=()

          if (( $# > 0 )) && [[ "$1" != -* ]]; then
            host=$1
            shift
            ssh_args=("$@")
          else
            ssh_args=("$@")
            host=$(pick_host)
          fi

          exec ${pkgs.openssh}/bin/ssh -t "''${ssh_args[@]}" "$host" "$remote_tmux_command"
        '';
      };

      tmuxSessionPicker = pkgs.writeShellApplication {
        name = "tmux-session-picker";
        runtimeInputs = with pkgs; [
          coreutils
          fzf
          gawk
          tmux
        ];
        text = ''
          set -euo pipefail

          preview_session() {
            local session_name=$1
            local active_pane

            ${pkgs.tmux}/bin/tmux list-windows -t "$session_name" -F 'window #I#{?window_active,*, }: #W (#{window_panes} panes)'
            printf '\n'
            ${pkgs.tmux}/bin/tmux list-panes -t "$session_name" -F 'pane #P#{?pane_active,*, }: #{pane_current_command} [#{pane_width}x#{pane_height}] #{pane_title}'

            active_pane="$(${pkgs.tmux}/bin/tmux list-panes -t "$session_name" -F '#{?pane_active,#{pane_id},}' | ${pkgs.gawk}/bin/awk 'NF { print; exit }')"

            if [[ -n "$active_pane" ]]; then
              printf '\nActive pane preview:\n\n'
              ${pkgs.tmux}/bin/tmux capture-pane -p -e -t "$active_pane" \
                | ${pkgs.gawk}/bin/awk 'length(lines) == 20 { for (i = 1; i < 20; i++) lines[i] = lines[i + 1]; lines[20] = $0; next } { lines[length(lines) + 1] = $0 } END { for (i = 1; i <= length(lines); i++) print lines[i] }'
            fi
          }

          if (( $# == 2 )) && [[ "$1" == "--preview-session" ]]; then
            preview_session "$2"
            exit 0
          fi

          mapfile -t sessions < <(${pkgs.tmux}/bin/tmux list-sessions -F '#{session_name}' 2>/dev/null || true)

          if (( ''${#sessions[@]} == 0 )); then
            exec ${pkgs.tmux}/bin/tmux
          fi

          if (( ''${#sessions[@]} == 1 )); then
            exec ${pkgs.tmux}/bin/tmux attach-session -t "''${sessions[0]}"
          fi

          selected_session=$(printf '%s\n' "''${sessions[@]}" | ${pkgs.fzf}/bin/fzf \
            --prompt='tmux session> ' \
            --height=40% \
            --preview='tmux-session-picker --preview-session {}' \
            --preview-window='right,60%,border-left')

          if [[ -z "$selected_session" ]]; then
            exit 0
          fi

          exec ${pkgs.tmux}/bin/tmux attach-session -t "$selected_session"
        '';
      };

    in
    {
      options.local.tmuxRemote.enable = lib.mkOption {
        type = lib.types.bool;
        default = shellToolset == "maximal";
        description = "Enable system-wide remote tmux helpers and bindings.";
      };

      options.local.tmuxRemote.niriTerminalOverride.enable = lib.mkEnableOption "tmux-oriented Niri terminal keybindings";

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          environment.systemPackages = [
            pkgs.fzf
            pkgs.openssh
            pkgs.tmux
            sshTmux
            tmuxSessionPicker
          ];

          programs.tmux.extraConfig = lib.mkIf config.programs.tmux.enable ''
            bind S display-popup -E "${lib.getExe sshTmux}"
          '';
        })

        (lib.mkIf (
          cfg.enable
          && cfg.niriTerminalOverride.enable
          && lib.attrByPath [ "programs" "niri" "enable" ] false config
        ) {
          programs.niri.package = lib.mkForce (self.wrappers.niri.wrap {
            inherit pkgs;
            browser = config.niri.browser;
            picker = config.local.niri.picker;
            settings.binds."Mod+Return" = lib.mkForce {
              spawn-sh = "${lib.getExe pkgs.kitty} -e tmux-session-picker";
            };
            settings.binds."Mod+Shift+Return".spawn-sh = "${lib.getExe pkgs.kitty} -e tmux";
          });

          services.displayManager.sessionPackages = lib.mkForce [ config.programs.niri.package ];
        })
      ];
    };
  };
}
