{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.rust = pkgs.mkShell {
        packages = with pkgs; [
          cargo
          clippy
          rust-analyzer
          rustc
          rustfmt
        ];
      };
    };
}
