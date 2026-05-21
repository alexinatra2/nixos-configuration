{ lib, ... }:
{
  flake.modules.homeManager.opencode =
    {
      pkgs,
      ...
    }:
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        extraPackages = [ pkgs.bun ];
        settings.autoupdate = false;
        skills.caveman = builtins.readFile ./opencode/caveman/SKILL.md;
      };
    };
}
