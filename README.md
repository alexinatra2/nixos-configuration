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

## Tailscale And Headscale Hosts

The shared NixOS module is `self.nixosModules.tailscale`. Each host selects its control plane through `local.tailscale`.

Hosted Tailscale host example:

```nix
{
  local.tailscale = {
    enable = true;
    authKeySecretName = "tailscale/authkey";
    expectedTailnet = "taila26075.ts.net";
  };
}
```

Self-hosted Headscale host example:

```nix
{
  local.tailscale = {
    enable = true;
    authKeySecretName = "headscale/authkey";
    loginServer = "https://headscale.woodservant.com";
    expectedTailnet = "tailnet.woodservant.com";
  };
}
```

Available host options:

- `local.tailscale.enable`
- `local.tailscale.authKeyFile`
- `local.tailscale.authKeySecretName`
- `local.tailscale.hostname`
- `local.tailscale.loginServer`
- `local.tailscale.expectedTailnet`
- `local.tailscale.tags`

Secret values:

- Hosted Tailscale: the secret file must contain a hosted Tailscale auth key.
- Headscale: the secret file must contain a Headscale pre-auth key created on `https://headscale.woodservant.com`.

Migration caveats:

- A single `tailscaled` instance can only be enrolled in one control plane at a time.
- Changing `local.tailscale.loginServer` and rebuilding does not reliably migrate an already-enrolled machine by itself.
- For an existing machine, rebuild with the new secret and `loginServer`, then re-register it with a manual reset path such as `sudo tailscale logout` followed by `sudo systemctl restart tailscaled-autoconnect.service`.
- If the daemon still keeps the old control-plane state, stop `tailscaled` and clear its state before re-enrolling.

Service exposure caveat:

- `modules/features/vaultwarden.nix` no longer relies on `tailscale serve --https`, because that certificate path is tied to hosted Tailscale features.
- Vaultwarden now expects a private CA certificate and a private leaf certificate for `warden.tailnet.woodservant.com`.

## Vaultwarden Private CA

Vaultwarden is exposed privately on the Headscale tailnet at `https://warden.tailnet.woodservant.com`.

Generate a private CA and a server certificate manually. The files you need are:

- `root-ca.crt`
- `root-ca.key`
- `warden.tailnet.woodservant.com.crt`
- `warden.tailnet.woodservant.com.key`

You may also have an OpenSSL extension file such as `warden.tailnet.woodservant.com.ext`; that file is not needed at runtime.

Store the server certificate and key in your secrets repo under these keys:

- `vaultwarden/tls/cert`
- `vaultwarden/tls/key`

Store the root CA certificate as a tracked file at:

- `modules/targets/hosts/certs/woodservant-tailnet-root-ca.crt`

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#warden
```

Notes:

- `warden` serves Vaultwarden over `nginx` on tailnet port `443` only.
- `atlas` and `warden` trust `modules/targets/hosts/certs/woodservant-tailnet-root-ca.crt` declaratively through `security.pki.certificateFiles`.
- Linux Firefox is configured to import enterprise roots, so fresh machines should trust the Vaultwarden certificate after rebuild.
- Other Firefox-family browsers may still need a manual root CA import.
