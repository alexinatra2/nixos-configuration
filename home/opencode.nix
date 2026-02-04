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

      commands = {
        commit = ''
          # Commit Command

          Create a git commit with proper message formatting.
          Usage: /commit [message]

          ## Behavior
          - If no commit message is provided:
            1. The agent analyzes recent staged changes (git diff --cached).
            2. It proposes a concise, conventional commit message.
            3. The agent asks for confirmation:  
               “Proposed commit message: <message>. Apply it?”
            4. If confirmed, it creates the commit.
            5. If declined, it prompts the user to enter a revised message.

          ## Guidelines
          - Follow the Conventional Commits format (e.g. `feat:`, `fix:`, `docs:`).
          - Keep messages under 80 characters.
          - Focus on the *why* and *what*, not the *how*.
        '';
        summarize = ''
          # Summarize Command

          Summarize the purpose and recent changes of the current project.
          Usage: /summarize [--since <commit> | --file <path> | --context <topic>]

          ## Behavior
          - If no context or message is given:
            1. The agent inspects recent commits or files modified in the last N commits.
            2. It drafts a summary describing key themes and technical changes.
            3. The agent presents the summary and asks for confirmation.
            4. If the user declines, they are prompted to provide or refine the summary manually.

          ## Guidelines
          - Summaries should be concise but informative (3–5 sentences).
          - Include context: what changed and why.
          - Avoid raw diffs; prefer natural explanations.
        '';
      };

      rules = ''
        # Project-Wide Development Rules

        ## Code Editing and Refactoring Discipline

        - Always modify the minimal amount of code necessary to fulfill the request.  
          Avoid broad or stylistic rewrites unless explicitly approved.
        - Before any refactor or structural change, scan the entire codebase to detect
          existing APIs, helper functions, or patterns that could conflict with or duplicate
          the new implementation.
        - When refactoring, ensure internal naming, error handling, and interface shapes
          remain consistent across modules.

        ## Coding Style and Paradigm

        - Prefer a **functional or declarative** style in languages that support it.
          Use pure functions, immutability, and composition whenever practical.
        - Follow the common community conventions of the language in use
          (e.g., idiomatic Rust modules, Kotlin data classes, React functional components).
        - Keep explanations **concise and factual**—avoid verbose or speculative reasoning
          when describing code or design choices.

        ## Code Style Documentation

        - If a `CODESTYLE.md` or `docs/code-style.md` file exists, update it whenever a change
          introduces a new rule or deviates from an existing one.
        - When adding new conventions, clearly justify *why* they are needed and how they align
          with existing style principles.

        ## External References

        - Load external rule or guideline files (e.g., `@rules/general.md`)
          only when they are explicitly referenced in the current task.
        - Treat loaded files as authoritative for their domain, and follow referenced files
          recursively when instructed.

        ## Summary

        These rules define the project’s working ethic:
        precision over verbosity, declarative design over imperative sprawl,
        and consistency across the entire codebase.
      '';
    };
  };
}
