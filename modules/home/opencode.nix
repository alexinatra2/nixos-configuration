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
    in
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        settings.mcp."computer-use".enabled = false;
        skills.caveman = builtins.readFile cavemanSkill;
      };
    };
}
