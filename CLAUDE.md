# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake-based configuration repository for user "alexander" containing system and home-manager configurations. It uses modern NixOS patterns with flakes and home-manager for declarative system management.

## Build and Deployment Commands

### System Configurations
- `sudo nixos-rebuild switch --flake .#nixos` - Deploy the basic nixos configuration
- `sudo nixos-rebuild switch --flake .#desktop` - Deploy the desktop configuration with GUI and gaming setup
- `sudo nixos-rebuild test --flake .#nixos` - Test configuration without making it default
- `sudo nixos-rebuild boot --flake .#desktop` - Set configuration to activate on next boot

### Home Manager
- `home-manager switch --flake .#alexander` - Deploy home-manager configuration for user alexander
- `home-manager --help` - Show available home-manager commands

### Flake Operations
- `nix flake update` - Update all flake inputs (nixpkgs, home-manager, etc.)
- `nix flake show` - Show all available configurations and outputs
- `nix flake check` - Validate flake configuration

### Development and Testing
- `nix run .#apps.nixos-vm` - Start VM for testing nixos configuration
- `nixfmt-rfc-style .` - Format all .nix files using the project's formatter
- `nix search nixpkgs <package>` - Search for packages in nixpkgs

### Using nh Helper (Recommended)
The configuration includes `nh` (NixOS Helper) which provides convenient commands:
- `nh os switch` - Rebuild and switch system configuration
- `nh home switch` - Rebuild and switch home-manager configuration
- `nh clean all` - Clean old generations (configured to keep last 3, last 4 days)

## Architecture

### Flake Structure
- **flake.nix**: Main flake configuration defining system and home configurations
- **flake.lock**: Pinned input versions for reproducible builds

### System Configurations
Two system configurations are available:
1. **nixos**: Basic headless configuration (hosts/nixos/)
2. **desktop**: Full desktop with GNOME, gaming, and development tools (hosts/desktop/)

### Home Configuration
- **home.nix**: Main home-manager entry point for user alexander
- **home/**: Modular home-manager configurations (tmux, shell, git, firefox, stylix)
- **nvf-configuration/**: Neovim configuration using nvf framework

### Key Modules
- **modules/**: System-level modules (dconf, virtualization)
- **stylix**: System-wide theme management via stylix input
- **nvf**: Neovim configuration framework

### Host-Specific Configurations
- **hosts/nixos/**: Headless server configuration with SSH and Cockpit
- **hosts/desktop/**: Desktop configuration with GNOME, NVIDIA, gaming, and development tools

### Development Environment
- Neovim configured via nvf with LSP, telescope, and development plugins
- Development packages: cargo, gcc, nodejs, pnpm, ripgrep
- IDEs: IntelliJ IDEA Ultimate, RustRover
- Terminal: Kitty with tmux

### Key Features
- NVIDIA GPU support with prime offload (desktop config)
- Gaming setup with Steam and gamemode (desktop config)
- Virtualization with libvirt and virt-manager
- Docker support
- Android development with ADB
- Stylix for consistent theming across applications

### Username and Paths
- Default username: "alexander"
- Configuration path: `/home/alexander/nixos-configuration`
- Flake configured to use this path for nh operations

## File Organization

```
├── flake.nix              # Main flake configuration
├── home.nix               # Home-manager entry point
├── hosts/                 # Host-specific configurations
│   ├── nixos/            # Basic/server configuration
│   └── desktop/          # Desktop configuration
├── home/                  # Home-manager modules
├── modules/               # System modules
└── nvf-configuration/     # Neovim configuration
```

When making changes:
- System-level changes go in hosts/ or modules/
- User-level changes go in home/ or home.nix
- Editor configuration goes in nvf-configuration/
- Always test changes with `nixos-rebuild test` before switching
- Use nixfmt-rfc-style for consistent formatting