{
  inputs,
  pkgs,
  raycastRevision,
  vicinaeLib,
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  nativePackages = inputs.vicinae-extensions.packages.${system};
  nativeExtensionNames = [
    "nix"
    "niri"
    "firefox"
    "player-pilot"
    "pulseaudio"
    "podman"
    "port-killer"
    "process-manager"
    "ssh"
    "github"
    "power-profile"
  ];

  screenshot = {
    installName = "screenshot";
    package = pkgs.buildNpmPackage {
      pname = "vicinae-screenshot";
      version = "0";
      src = ./screenshot;
      npmDepsHash = "sha256-mE+2Ab/SIg9+t6cgfwWOMkTaRIZ5CIcYSLYoQKkDOcY=";

      buildPhase = ''
        runHook preBuild
        npm run typecheck
        npm run build -- --out=$out
        runHook postBuild
      '';
      dontNpmInstall = true;
    };
  };

  bluetooth = {
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
  };

  tailscale = {
    installName = "tailscale";
    package = vicinaeLib.mkRayCastExtension {
      name = "tailscale";
      rev = raycastRevision;
      hash = "sha256-Me989vaYwGEYUrdnjdiYoG0nVAs7qfEuvC+C1feNuI0=";
    };
  };

  searchNpm = {
    installName = "search-npm";
    package = vicinaeLib.mkRayCastExtension {
      name = "search-npm";
      rev = raycastRevision;
      hash = "sha256-mjkjxe/eWKoY9w2nUJ/ELXIHIQ+w+RQAN3AD0LNyRkE=";
    };
  };

  spotifyPlayer = {
    installName = "spotify-player";
    package = vicinaeLib.mkRayCastExtension {
      name = "spotify-player";
      rev = raycastRevision;
      hash = "sha256-atPAUm3eqVUUepfAs/N3lOs2G2qHztKHvn6cL9GD+GU=";
      nativeBuildInputs = [ pkgs.jq ];
      postPatch = ''
        substituteInPlace src/helpers/isMenuBarAvailable.ts \
          --replace-fail \
            'return process.platform !== "win32";' \
            'return process.platform === "darwin";'
        substituteInPlace src/helpers/isSpotifyInstalled.ts \
          --replace-fail \
            'export async function checkSpotifyApp() {' \
            'export async function checkSpotifyApp() {
            if (process.platform !== "darwin" && process.platform !== "win32") {
              isSpotifyInstalled = false;
              return false;
            }'
        jq '.commands |= map(select(.name != "nowPlayingMenuBar" and .name != "generatePlaylist"))' \
          package.json > package.json.new
        mv package.json.new package.json
      '';
    };
  };

  bitwarden = {
    installName = "bitwarden";
    package = vicinaeLib.mkRayCastExtension {
      name = "bitwarden";
      rev = raycastRevision;
      hash = "sha256-kSIfQcnAZuwT9ipXOJR3nMLlwS4OXX03mP5jX1ktwnw=";
    };
  };
in
map (name: {
  installName = "vicinae-extension-${name}-0";
  package = nativePackages.${name};
}) nativeExtensionNames
++ [
  screenshot
  bluetooth
  tailscale
  searchNpm
  spotifyPlayer
  bitwarden
]
