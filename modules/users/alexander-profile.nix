{ self, inputs, ... }:
let
  user = "alexander";
  homeDirectory = "/home/${user}";
  nixvimPackage = inputs.nixvim-config.packages.x86_64-linux.default;
in
{
  flake.nixosModules."user-alexander-profile" =
    {
      pkgs,
      config,
      ...
    }:
    {
      sops.secrets."llms/huggingface/token" = {
        owner = user;
        mode = "0400";
      };

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
        nodejs
        python313Packages.huggingface-hub
        uv
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
        HF_TOKEN_PATH = config.sops.secrets."llms/huggingface/token".path;
        VISUAL = "nvim";
      };

      programs.nh = {
        enable = true;
        flake = homeDirectory + "/nixos-configuration";
        clean.enable = false;
      };
    };
}
