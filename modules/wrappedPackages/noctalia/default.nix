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
          if [ "$#" -ne 1 ]; then
            printf 'usage: %s TARGET\n' "$0" >&2
            exit 2
          fi

          ${lib.getExe noctaliaShell} ipc call state all > "$1"
        '';
      };
    in
    {
      packages = {
        inherit syncNoctaliaSettings;
        "noctalia-shell" = noctaliaShell;
      };
      apps.sync-noctalia-settings = {
        meta.description = "Export the current Noctalia state to a JSON file.";
        type = "app";
        program = "${syncNoctaliaSettings}/bin/sync-noctalia-settings";
      };
    };
}
