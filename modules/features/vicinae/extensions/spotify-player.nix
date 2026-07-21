{
  pkgs,
  raycastRevision,
  vicinaeLib,
  ...
}:
{
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
}
