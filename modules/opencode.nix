{ inputs, system, ... }:
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
  };

  # Skill files — symlinked, changes visible immediately
  xdg.configFile = {
    "opencode/skills".source = "${inputs.agents}/skills";
    "opencode/context".source = "${inputs.agents}/context";
    "opencode/commands".source = "${inputs.agents}/commands";
    "opencode/prompts".source = "${inputs.agents}/prompts";
  };

  # Agent config — embedded into config.json (requires home-manager switch)
  programs.opencode.settings.agent = builtins.fromJSON (
    builtins.readFile "${inputs.agents}/agents/agents.json"
  );

  # Skills runtime — ensures opencode always has script dependencies
  home.packages = [ inputs.agents.packages.${system}.skills-runtime ];
}
