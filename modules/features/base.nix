{ self, inputs, ... }:
let
  defaultUsername = "alexander";
in
{
  flake.modules.homeManager.base =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home = {
        username = lib.mkDefault defaultUsername;
        homeDirectory = lib.mkDefault (
          if pkgs.stdenv.isDarwin then "/Users/${defaultUsername}" else "/home/${defaultUsername}"
        );
        packages =
          (with pkgs; [
            gcc
            jdk21
            lazydocker
            lazysql
            nixfmt
            nodejs
            pnpm
            fd
            ripgrep
            tree
            unzip
            yazi
            typst
            just
            telegram-desktop
            bc
            uutils-coreutils-noprefix
            (writeShellApplication {
              name = "ns";
              runtimeInputs = [
                fzf
                nix-search-tv
              ];
              text = builtins.readFile "${nix-search-tv.src}/nixpkgs.sh";
            })
            (writeShellApplication {
              name = "vim-temp";
              runtimeInputs = [ neovim ];
              text = ''
                if [ $# -eq 0 ]; then
                  echo "Usage: vim-temp <command> [args...]" >&2
                  exit 1
                fi
                nvim -R <( "$@" 2>&1 )
              '';
            })
          ])
          ++ lib.optionals pkgs.stdenv.isLinux (
            with pkgs;
            [
              spotify
              ausweisapp
              xclip
              disktui
            ]
          );
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;

      nixpkgs.config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };

    };
}
