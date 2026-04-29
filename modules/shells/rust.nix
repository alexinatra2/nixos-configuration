{ ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    {
      devShells.rust = pkgs.mkShell {
        packages =
          (with pkgs; [
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
          ])
          ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.mold ];

        RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}/lib/rustlib/src/rust/library";
      };
    };
}
