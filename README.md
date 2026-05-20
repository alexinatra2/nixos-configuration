# nixos-configuration

This flake exposes two kinds of outputs:

- portable wrapped packages built from selected Home Manager modules
- full NixOS and Home Manager configurations for owned machines

The portable packages are meant for quick reuse on another machine without switching that machine over to your full Home Manager config.

## Portable Packages

Currently exposed on Linux:

- `.#tmux`
- `.#neovim`
- `.#git`
- `.#opencode`
- `.#obsidian`
- `.#pdf`
- `.#firefox`

### Run a wrapped package

```bash
nix run .#tmux
nix run github:alexinatra/nixos-configuration#opencode
```

If you are testing local, uncommitted changes, use `path:.#<name>` so Nix evaluates the working tree instead of only tracked Git content.

### Install a wrapped package into your profile

```bash
nix profile install .#neovim
nix profile install github:alexinatra/nixos-configuration#firefox
```

### Open a shell with a wrapped package available

```bash
nix shell .#git
nix shell github:alexinatra/nixos-configuration#pdf
```

## Full Configurations

### Home Manager profile

```bash
home-manager switch --flake .#alexander
```

### NixOS host

```bash
sudo nixos-rebuild switch --flake .#atlas
sudo nixos-rebuild switch --flake .#warden
```

## Package Sources Of Truth

Portable packages are intentionally generated from the same Home Manager modules used by the full profile.

- `tmux` from `modules/features/tmux.nix`
- `neovim` from `modules/features/neovim/default.nix`
- `git` from `modules/features/git.nix`
- `opencode` from `modules/features/opencode.nix`
- `obsidian` from `modules/features/obsidian.nix`
- `pdf` from `modules/features/pdf.nix`

This keeps the package configuration reusable while avoiding a second hand-maintained package-specific config layer.

## Notes

- The Home Manager backed wrapped packages are currently exported on Linux only.
- `obsidian` and `firefox` require unfree packages to be allowed by the caller's Nix configuration.
- Host-level concerns like boot, services, hardware, users, secrets bootstrapping, and desktop/session wiring stay in `nixosModules`.
- Direct wrapper packages that are a better fit than HM extraction, such as `firefox`, remain separate.
