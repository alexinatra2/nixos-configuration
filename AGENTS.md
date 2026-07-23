# Agent Instructions

## Nix Module Architecture

- Define hand-written reusable NixOS modules under `modules/**/default.nix` and export them as `flake.nixosModules.<name>`.
- Consume exported modules from host configurations through `self.nixosModules`; do not import them with relative paths.
- Keep relative imports for generated or intrinsically host-specific files such as `hardware-configuration.nix`.
- Module discovery is automatic through `modules/default.nix`; do not register individual feature modules in `flake.nix`.
