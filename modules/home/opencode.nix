{ self, inputs, ... }:
{
  flake.modules.homeManager.opencode =
    {
      lib,
      options,
      system,
      ...
    }:
    let
      hasOpencode = options ? programs.opencode;
      hasAgents = inputs ? agents;
    in
    {
      config = lib.mkIf hasOpencode (
        lib.mkMerge [
          {
            programs.opencode = {
              enable = true;
              enableMcpIntegration = true;
              settings.mcp."computer-use".enabled = false;
            };
          }
          (lib.mkIf hasAgents {
            xdg.configFile = {
              "opencode/skills".source = "${inputs.agents}/skills";
              "opencode/context".source = "${inputs.agents}/context";
              "opencode/commands".source = "${inputs.agents}/commands";
              "opencode/prompts".source = "${inputs.agents}/prompts";
            };

            programs.opencode.settings.agent = builtins.fromJSON (
              builtins.readFile "${inputs.agents}/agents/agents.json"
            );

            home.packages = [ inputs.agents.packages.${system}.skills-runtime ];
          })
        ]
      );
    };
}
