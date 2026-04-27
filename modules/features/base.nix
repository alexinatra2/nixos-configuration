{ self, inputs, ... }:
{
  flake.modules.homeManager.base =
    {
      pkgs,
      username,
      lib,
      ...
    }:
    {
      home = {
        username = username;
        homeDirectory = lib.mkDefault (
          if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
        );
        packages =
          (with pkgs; [
            cargo
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

      firefox = {
        enable = lib.mkDefault true;
        enabledExtensions = {
          default = true;
          react-development = true;
        };
        defaultSearchEngine = "duckduckgo";
        searchEngines = {
          duckduckgo = true;
          google = true;
          google-scholar = true;
          home-manager-options = true;
          nixos-options = true;
          nixpkgs = true;
        };
      };

    };
}
