{ ... }:
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

      opencodeClearSessions = pkgs.writeShellApplication {
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
    in
    {
      home.packages = [ opencodeClearSessions ];

      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        settings.mcp."computer-use".enabled = false;
        skills.caveman = builtins.readFile cavemanSkill;
      };
    };
}
