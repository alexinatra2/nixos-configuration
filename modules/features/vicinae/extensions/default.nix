{
  enabled,
  inputs,
  lib,
  pkgs,
  raycastRevision,
  vicinaeLib,
}:
let
  nativePackages = inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system};
  nativeExtension = name: {
    installName = "vicinae-extension-${name}-0";
    package = nativePackages.${name};
  };
  args = {
    inherit
      inputs
      nativeExtension
      pkgs
      raycastRevision
      vicinaeLib
      ;
  };
  definitions = {
    bitwarden = import ./bitwarden.nix args;
    bluetooth = import ./bluetooth.nix args;
    firefox = import ./firefox.nix args;
    github = import ./github.nix args;
    niri = import ./niri.nix args;
    nix = import ./nix.nix args;
    player-pilot = import ./player-pilot.nix args;
    podman = import ./podman.nix args;
    port-killer = import ./port-killer.nix args;
    power-profile = import ./power-profile.nix args;
    process-manager = import ./process-manager.nix args;
    pulseaudio = import ./pulseaudio.nix args;
    screenshot = import ./screenshot.nix args;
    search-npm = import ./search-npm.nix args;
    spotify-player = import ./spotify-player.nix args;
    ssh = import ./ssh.nix args;
    tailscale = import ./tailscale.nix args;
  };
  extensions = lib.attrValues (lib.filterAttrs (name: _: enabled.${name}.enable) definitions);
  disabledExtensions = lib.attrValues (
    lib.filterAttrs (name: _: !enabled.${name}.enable) definitions
  );
in
{
  options = lib.mapAttrs (name: _: {
    enable = lib.mkEnableOption "Vicinae ${name} extension";
  }) definitions;

  inherit disabledExtensions extensions;

  providerSettings = lib.foldl' lib.recursiveUpdate { } (
    map (extension: extension.settings or { }) extensions
  );

  runtimeTools = lib.unique (lib.concatMap (extension: extension.runtimeTools or [ ]) extensions);
}
