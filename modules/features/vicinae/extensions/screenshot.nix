{ pkgs, ... }:
{
  installName = "screenshot";
  package = pkgs.buildNpmPackage {
    pname = "vicinae-screenshot";
    version = "0";
    src = ../screenshot;
    npmDepsHash = "sha256-mE+2Ab/SIg9+t6cgfwWOMkTaRIZ5CIcYSLYoQKkDOcY=";

    buildPhase = ''
      runHook preBuild
      npm run typecheck
      npm run build -- --out=$out
      runHook postBuild
    '';
    dontNpmInstall = true;
  };
}
