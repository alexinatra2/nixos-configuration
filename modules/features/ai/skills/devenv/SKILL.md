---
name: devenv
description: Use when creating or updating a standard devenv.sh project environment from a project specification.
---

# Devenv

Create or update `devenv.nix`, `devenv.yaml`, and related generated files.

## Discover

1. Inspect manifests, lockfiles, scripts, documentation, existing devenv files,
   and repository conventions.
2. Treat the explicit project specification as authoritative. Infer only
   requirements directly supported by repository evidence; ask about material
   ambiguity.
3. Consult current official devenv documentation through Context7 for syntax
   and options. Use the Nix MCP for nixpkgs package names and availability. Do
   not guess attributes or devenv options.

## Configure

1. For a new environment, use the standard `devenv init` layout. For an existing
   environment, preserve its structure and unrelated settings.
2. Add only requested packages, languages, environment variables, scripts,
   tasks, processes, services, hooks, and inputs.
3. Prefer devenv language and service modules over hand-built equivalents when
   they satisfy the specification.
4. Keep secrets out of tracked configuration. Reference environment variables
   or the repository's existing secret mechanism.
5. Keep input declarations in `devenv.yaml`. Do not edit `devenv.lock`
   manually or update unrelated inputs.
6. Follow repository formatting and `.envrc` conventions. Do not add
   dependencies, services, hooks, or setup side effects without evidence.

## Validate

1. Format changed Nix files with the repository's formatter when available.
2. Run `devenv info` to evaluate the environment.
3. Run `devenv test` when tests or git hooks are configured.
4. Run focused project commands inside `devenv shell -- <command>` when needed
   to verify the specification.
5. Report changed files, generated lockfile changes, checks, and unresolved
   requirements.
