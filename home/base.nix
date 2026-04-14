{
  pkgs,
  username,
  lib,
  ...
}:
{
  home = {
    username = "${username}";
    homeDirectory = lib.mkDefault "/home/${username}";
    packages = with pkgs; [
      cargo
      gcc
      jdk21
      nerd-fonts.jetbrains-mono
      lazydocker
      lazysql
      nixfmt
      nodejs
      pnpm
      ripgrep
      spotify
      unzip
      xclip
      typst
      just
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
    ];
    stateVersion = "24.11";
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

  neovim.enable = true;

  plasmaOverrides.enable = true;

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      # cursor_trail = 2;
      background_opacity = "0.95";
    };
  };
}
