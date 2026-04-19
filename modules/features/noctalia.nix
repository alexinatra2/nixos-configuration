{ self, inputs, ... }:
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
      myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
      };
      syncNoctaliaSettings = pkgs.writeShellApplication {
        name = "sync-noctalia-settings";
        text = ''
          ${lib.getExe myNoctalia} ipc call state all > ~/nixos-configuration/modules/features/noctalia.json
        '';
      };
    in
    if pkgs.stdenv.isLinux then
      {
        packages = {
          inherit myNoctalia syncNoctaliaSettings;
        };
        apps.sync-noctalia-settings = {
          type = "app";
          program = "${syncNoctaliaSettings}/bin/sync-noctalia-settings";
        };
      }
    else
      { };
}
