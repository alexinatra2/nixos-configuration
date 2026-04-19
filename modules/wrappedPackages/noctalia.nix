{ inputs, ... }:
{
  perSystem =
    {
      system,
      lib,
      ...
    }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      noctaliaShell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
      };
      syncNoctaliaSettings = pkgs.writeShellApplication {
        name = "sync-noctalia-settings";
        text = ''
          ${lib.getExe noctaliaShell} ipc call state all > ~/nixos-configuration/modules/wrappedPackages/noctalia.json
        '';
      };
    in
    if pkgs.stdenv.isLinux then
      {
        packages = {
          inherit syncNoctaliaSettings;
          "noctalia-shell" = noctaliaShell;
        };
        apps.sync-noctalia-settings = {
          type = "app";
          program = "${syncNoctaliaSettings}/bin/sync-noctalia-settings";
        };
      }
    else
      { };
}
