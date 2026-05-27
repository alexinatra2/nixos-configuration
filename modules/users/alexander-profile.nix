{ inputs, ... }:
let
  user = "alexander";
  homeDirectory = "/home/${user}";
  nixvimPackage = inputs.nixvim-config.packages.x86_64-linux.default;
in
{
  flake.nixosModules."user-alexander-profile" =
    { pkgs, ... }:
    {
      users.users.${user}.packages = with pkgs; [
        lazydocker
        fd
        ripgrep
        tree
        unzip
        yazi
        typst
        just
        uutils-coreutils-noprefix
        spotify
        xclip
        nixvimPackage
        ollama
        python313Packages.huggingface-hub
        (writeShellApplication {
          name = "ns";
          runtimeInputs = [
            fzf
            nix-search-tv
          ];
          text = builtins.readFile "${nix-search-tv.src}/nixpkgs.sh";
        })
      ];

      environment.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      programs.nh = {
        enable = true;
        flake = homeDirectory + "/nixos-configuration";
        clean.enable = false;
      };
    };
}
