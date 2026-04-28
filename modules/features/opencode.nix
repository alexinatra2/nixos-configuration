{ lib, ... }:
let
  mkOpencodeClearSessions = pkgs:
    pkgs.writeShellApplication {
      name = "opencode-clear-sessions";
      runtimeInputs = with pkgs; [ opencode ripgrep findutils ];
      text = ''
        set -euo pipefail

        mapfile -t sessions < <(opencode session list | rg -o 'ses_[A-Za-z0-9]+')

        if [ "''${#sessions[@]}" -eq 0 ]; then
          echo "No OpenCode sessions found."
          exit 0
        fi

        printf '%s\n' "''${sessions[@]}" | xargs -r -n1 opencode session delete
        echo "Deleted ''${#sessions[@]} OpenCode sessions."
      '';
    };

  mkOpencodeSessionList = pkgs:
    pkgs.writeShellApplication {
      name = "opencode-session-list";
      runtimeInputs = with pkgs; [ opencode gawk ];
      text = ''
        set -euo pipefail

        opencode db --format tsv "
          select id, title, directory
          from session
          where time_archived is null
          order by time_updated desc
          limit 200
        " | awk -F '\t' -v home="$HOME" 'BEGIN { OFS = "\t" }
          NR == 1 { next }
          {
            dir = $3
            sub("^" home, "~", dir)
            print $1, $2, dir
          }'
      '';
    };

  mkOpencodeLatestSession = pkgs:
    pkgs.writeShellApplication {
      name = "opencode-latest-session";
      runtimeInputs = with pkgs; [ opencode gawk ];
      text = ''
        set -euo pipefail

        session_id=$(
          opencode db --format tsv "
            select id
            from session
            where time_archived is null
            order by time_updated desc
            limit 1
          " | awk 'NR == 2 { print $1 }'
        )

        if [ -z "$session_id" ]; then
          echo "No OpenCode sessions found."
          exit 1
        fi

        exec opencode --session "$session_id"
      '';
    };
in
{
  flake.modules.homeManager.opencode =
    {
      pkgs,
      ...
    }:
    let
      cavemanSkill = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/JuliusBrussee/caveman/main/caveman/SKILL.md";
        hash = "sha256-+cg6KyD8OzUDr50a4c8gmMn4w9MmwgPCNrFg6+gayPA=";
      };

      opencodeClearSessions = mkOpencodeClearSessions pkgs;
      opencodeSessionList = mkOpencodeSessionList pkgs;
      opencodeLatestSession = mkOpencodeLatestSession pkgs;
    in
    {
      home.packages = [
        opencodeClearSessions
        opencodeLatestSession
        opencodeSessionList
      ];

      programs.zsh.initContent = lib.mkAfter ''
        opencode-session-widget() {
          local session_id

          session_id=$(opencode-session-list | fzf \
            --delimiter=$'\t' \
            --with-nth=2,3 \
            --layout=reverse-list \
            --height=40% \
            --border=rounded \
            --info=inline-right \
            --prompt='OpenCode > ' \
            --header='Recent sessions, newest first' \
            --no-sort \
            --cycle \
            | cut -f1) || return

          if [ -n "$session_id" ]; then
            BUFFER="opencode --session $session_id"
            zle accept-line
          fi
        }

        zle -N opencode-session-widget
        bindkey '^[o' opencode-session-widget
        bindkey -M viins '^[o' opencode-session-widget
      '';

      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        settings.mcp."computer-use".enabled = false;
        skills.caveman = builtins.readFile cavemanSkill;
      };
    };

  flake.nixosModules.opencode =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      opencodeLatestSession = mkOpencodeLatestSession pkgs;
    in
    {
      environment.systemPackages = [ opencodeLatestSession ];

      programs.niri.settings.binds = lib.mkIf config.programs.niri.enable {
        "Mod+C".spawn-sh = "opencode-latest-session";
      };
    };
}
