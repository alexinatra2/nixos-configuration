# nixos-configuration

Personal NixOS and Home Manager configuration for owned machines.

## What This Repo Does

- builds NixOS systems from `hosts/`
- builds the main Home Manager profile from `homes/`
- keeps shared modules in `modules/`

## Common Commands

Switch Home Manager:

```bash
home-manager switch --flake .#alexander
```

Switch a NixOS host:

```bash
sudo nixos-rebuild switch --flake .#atlas
```

## Layout

- `hosts/`: machine-specific NixOS config
- `homes/`: user Home Manager config
- `modules/`: reusable NixOS and Home Manager modules

## YubiKey Support

The shared NixOS YubiKey module is `self.nixosModules.yubikey`.

What it enables:

- `pcscd`
- `ssh-agent`
- YubiKey tooling like `ykman` and `opensc`
- optional PAM U2F auth for login, sudo, and tty login

Minimal host example:

```nix
{
  local.yubikey.enable = true;
}
```

If a machine should have the tooling but not YubiKey-backed login prompts:

```nix
{
  local.yubikey = {
    enable = true;
    pamAuth.enable = false;
  };
}
```

## YubiKey SSH Bootstrap

This is the manual bootstrap path for a fresh machine when both YubiKeys are physically present and the SSH credentials were created as resident keys.

Goal:

- recover the resident SSH credentials from the YubiKeys
- install the local key stubs into `~/.ssh/`
- then manually add whatever `~/.ssh/config` entries you want

### Assumptions

- the machine already has working NixOS or Home Manager basics
- OpenSSH on the machine supports security keys
- `ykman` is available
- you know the FIDO PIN for the YubiKeys
- the server already trusts the public keys

### 1. Make sure the machine sees the keys

Plug in the YubiKeys and run:

```bash
ykman list
```

If nothing is shown, fix that first.

### 2. Prepare `~/.ssh`

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

### 3. Recover resident SSH credentials

Run this in an empty temporary directory so the recovered files are easy to inspect:

```bash
mkdir -p ~/tmp/yubikey-ssh-bootstrap
cd ~/tmp/yubikey-ssh-bootstrap
ssh-keygen -K
```

What to expect:

- you may be asked for the FIDO PIN
- you may need to touch the YubiKey
- OpenSSH writes one or more recovered private key stubs and matching `.pub` files into the current directory

If both YubiKeys are plugged in and only one key shows up, run `ssh-keygen -K` again and touch the other device when prompted.

### 4. Identify the recovered keys

List the fingerprints:

```bash
ssh-keygen -lf *.pub
```

For the current Woodservant infra, the expected SSH key fingerprints are:

- main YubiKey: `SHA256:2ik03Uc+WMJL9tl/80b3S1Q94dH3Hno0kZExGyuwNz4`
- backup YubiKey: `SHA256:jnbK+WK0yGMYXY2rkeAb4gRrL6W0EDcyPtTo206cdbA`

Match the recovered files to those fingerprints.

### 5. Install the key stubs into `~/.ssh`

Copy the recovered files into canonical names:

```bash
cp <main-private-key-file> ~/.ssh/id_ed25519_sk
cp <main-private-key-file>.pub ~/.ssh/id_ed25519_sk.pub

cp <backup-private-key-file> ~/.ssh/id_ed25519_sk_backup
cp <backup-private-key-file>.pub ~/.ssh/id_ed25519_sk_backup.pub
```

Then fix permissions:

```bash
chmod 600 ~/.ssh/id_ed25519_sk ~/.ssh/id_ed25519_sk_backup
chmod 644 ~/.ssh/id_ed25519_sk.pub ~/.ssh/id_ed25519_sk_backup.pub
```

### 6. Verify the local key stubs

```bash
ssh-keygen -lf ~/.ssh/id_ed25519_sk.pub
ssh-keygen -lf ~/.ssh/id_ed25519_sk_backup.pub
```

Make sure the fingerprints still match the expected main and backup values above.

### 7. Add SSH config manually

This repo does not assume a universal host layout for YubiKey SSH use. After the key stubs exist, add the SSH config you want by hand.

Example pattern:

```sshconfig
Host some-host
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519_sk
  IdentityFile ~/.ssh/id_ed25519_sk_backup
```

If different users on the same host need different keys, use `Match host ... user ...` blocks.

### 8. Test each YubiKey explicitly

Test the main key:

```bash
ssh -i ~/.ssh/id_ed25519_sk <user>@<host>
```

Test the backup key:

```bash
ssh -i ~/.ssh/id_ed25519_sk_backup <user>@<host>
```

Then test the final host entry without `-i`.

### Notes

- If `ssh-keygen -K` does not recover a key, either the credential is not resident or the wrong YubiKey was used during recovery.
- `device not found` during SSH usually means the local stub points at a different YubiKey than the one currently plugged in.
- Do not delete an existing working local stub until the new machine is fully tested.

## Headscale

This repo uses Headscale, not hosted Tailscale.

Host example:

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

Useful host options:

- `local.tailscale.enable`
- `local.tailscale.authKeyFile`
- `local.tailscale.authKeySecretName`
- `local.tailscale.hostname`
- `local.tailscale.loginServer`
- `local.tailscale.expectedTailnet`
- `local.tailscale.tags`

If a machine was previously enrolled somewhere else, rebuilding alone may not move it cleanly. Re-enroll it manually if needed.

## Vaultwarden Private CA

Vaultwarden is exposed privately at `https://warden.tailnet.woodservant.com`.

Needed files:

- `root-ca.crt`
- `root-ca.key`
- `warden.tailnet.woodservant.com.crt`
- `warden.tailnet.woodservant.com.key`

Store these secrets:

- `vaultwarden/tls/cert`
- `vaultwarden/tls/key`

Tracked CA file location:

- `hosts/common/certs/woodservant-tailnet-root-ca.crt`

Then rebuild the host.
