{ ... }:
{
  flake.modules.homeManager."rust-dev" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.dev.rust;

      rustPackages =
        with pkgs;
        [
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
        ]
        ++ lib.optionals pkgs.stdenv.isLinux [ mold ];
    in
    {
      options.dev.rust = {
        enable = lib.mkEnableOption "Rust development tooling" // {
          default = true;
        };

        useSccache = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether Cargo should use sccache as a compiler wrapper.";
        };

        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Additional packages to install alongside the default Rust toolchain.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = rustPackages ++ cfg.extraPackages;

        home.sessionVariables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}/lib/rustlib/src/rust/library";

        xdg.configFile."cargo/config.toml".text = ''
          [alias]
          t = "nextest run"
          wt = "watch -x test"
          wc = "watch -x check"
          wclippy = "watch -x clippy"
        ''
        + lib.optionalString cfg.useSccache ''

          [build]
          rustc-wrapper = "${lib.getExe pkgs.sccache}"
        '';
      };
    };
}
