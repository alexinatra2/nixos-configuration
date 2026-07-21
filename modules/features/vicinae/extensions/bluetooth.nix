{
  inputs,
  pkgs,
  vicinaeLib,
  ...
}:
{
  installName = "vicinae-extension-bluetooth-0";
  package = vicinaeLib.mkVicinaeExtension {
    pname = "vicinae-extension-bluetooth";
    version = "0";
    src = "${inputs.vicinae-extensions}/extensions/bluetooth";
    npmFlags = [ "--legacy-peer-deps" ];
    npmInstallFlags = [ "--ignore-scripts" ];
    npmRebuildFlags = [ "--ignore-scripts" ];
    nativeBuildInputs = [ pkgs.jq ];
    postPatch = ''
      jq '
        del(.packages["node_modules/dbus-next"].optionalDependencies.usocket)
        | del(.packages["node_modules/usocket"])
      ' package-lock.json > package-lock.json.new
      mv package-lock.json.new package-lock.json
    '';
    preBuild = ''
      substituteInPlace node_modules/dbus-next/lib/connection.js \
        --replace-fail \
          "const usocket = require('usocket');" \
          "const usocket = { USocket: class { constructor () { throw new Error('usocket unavailable'); } } };"
    '';
    buildPhase = ''
      runHook preBuild
      npm run build -- --out=$out
      runHook postBuild
    '';
  };
  settings."@Gelei/vicinae-extension-bluetooth-0".preferences.connectionToggleable = true;
}
