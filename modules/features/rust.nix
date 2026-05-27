{ self, inputs, ... }:
{
  flake.modules.homeManager.rust =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bacon
        cargo
        cargo-deny
        cargo-edit
        cargo-expand
        cargo-nextest
        cargo-outdated
        cargo-watch
        clippy
        rust-analyzer
        rustc
        rustfmt
        sccache
        mold
      ];
    };
}
