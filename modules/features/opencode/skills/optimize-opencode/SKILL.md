---
name: optimize-opencode
description: Use ONLY when the user explicitly requests optimization of repository-local OpenCode configuration or MCP tools.
---

# Optimize OpenCode

Inspect local OpenCode config, repository files, and resolved config.

Enable only evidenced MCPs:
- Nix: `nixos`
- PDFs: `pdf-reader-mpc`
- Browser/UI/E2E: `playwright`
- Library docs: `context7`
- Web research: `duckduckgo-search`
- Slidev: `slidev-mcp`

Disable irrelevant inherited MCPs. Ask before removing explicit local tools.

Use local `mcp.<name>.enabled` overrides. Preserve `$schema`. Do not add tools
merely because they exist globally.

Keep static rules in prompts. Do not duplicate them through plugins.

Use bounded tool output and compaction pruning when absent. Validate resolved
config. Tell the user to restart OpenCode.
