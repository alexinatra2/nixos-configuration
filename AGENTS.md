# Agent Instructions

## Nix Module Architecture

- Define hand-written reusable NixOS modules under `modules/**/default.nix` and export them as `flake.nixosModules.<name>`.
- Consume exported modules from host configurations through `self.nixosModules`; do not import them with relative paths.
- Keep relative imports for generated or intrinsically host-specific files such as `hardware-configuration.nix`.
- Module discovery is automatic through `modules/default.nix`; do not register individual feature modules in `flake.nix`.

## Memory

- OpenViking provides cross-session memory via auto-recall and the `openviking_*` MCP tools.
- Use `openviking_recall` before broad searching or asking when work may depend on unstated prior decisions, preferences, conventions, deployment facts, or repository facts.
- Use repository scope by default. Current repository evidence wins.
- After substantive work, keep only verified, novel, durable, useful, atomic facts not readily discoverable from the repository.
- Exclude transient state, guesses, secrets, personal data, generated values, logs, and code-derived details. Check for duplicates and conflicts. If nothing qualifies, do not ask.
- Before mutation, show each exact subject, statement, scope, and action in one `question`. Offer approval and skip; treat free text as revision feedback.
- Write only approved facts with `openviking_remember` or `openviking_forget`. Never use Markdown memory.
