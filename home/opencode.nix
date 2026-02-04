{ config, lib, ... }:
let
  cfg = config.opencode;
in
{
  options.opencode = {
    enable = lib.mkEnableOption "OpenCode";

    agents = {
      build.enable = lib.mkEnableOption "the Build agent";
      plan.enable = lib.mkEnableOption "the Plan agent";
      explore.enable = lib.mkEnableOption "the Explore agent";
      chat.enable = lib.mkEnableOption "the Chat agent with web search";
      creative.enable = lib.mkEnableOption "the Creative brainstorming agent";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = lib.mkDefault null;
      enableMcpIntegration = true;

      # Merge the enabled agents into one attribute set
      agents = lib.mkMerge [
        (lib.attrsets.optionalAttrs cfg.agents.build.enable {
          build = ''
            # Build Agent
            You are a primary development agent with full tool access.
            Focus on code implementation and debugging.
          '';
        })

        (lib.attrsets.optionalAttrs cfg.agents.plan.enable {
          plan = ''
            # Plan Agent
            You are an analytical agent for planning and review.
            Keep temperature low.
          '';
        })

        (lib.attrsets.optionalAttrs cfg.agents.explore.enable {
          explore = ''
            # Explore Agent
            Read-only exploration of code; no editing.
          '';
        })

        (lib.attrsets.optionalAttrs cfg.agents.chat.enable {
          chat = ''
            # Chat Agent
            Conversational assistant with web search enabled.
          '';
        })

        (lib.attrsets.optionalAttrs cfg.agents.creative.enable {
          creative = ''
            # Creative Agent
            High-temperature brainstorming agent.
          '';
        })
      ];
    };
  };
}
