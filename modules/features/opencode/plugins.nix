{ pkgs }:
pkgs.buildNpmPackage {
  pname = "opencode-plugins";
  version = "1.0.0";
  src = ./plugins;
  npmDepsHash = "sha256-s1DgYzKodzwevWRx4MDqAyxGEd7Et3wGyLXcHarC0fU=";
  nativeBuildInputs = [
    pkgs.esbuild
    pkgs.git
  ];

  buildPhase = ''
    runHook preBuild
    esbuild plan-store.ts tmux-window-title.ts feature-worktree.ts repository-clone.ts --bundle --format=esm --platform=node --outdir=dist
    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    esbuild feature-worktree.test.ts plan-store.test.ts --bundle --format=esm --platform=node --outdir=dist/tests --out-extension:.js=.mjs
    node --test dist/tests/*.test.mjs
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 dist/plan-store.js "$out/plan-store.js"
    install -Dm644 dist/tmux-window-title.js "$out/tmux-window-title.js"
    install -Dm644 dist/feature-worktree.js "$out/feature-worktree.js"
    install -Dm644 dist/repository-clone.js "$out/repository-clone.js"
    runHook postInstall
  '';
}
