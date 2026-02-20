{
  flake.modules.nixos.environment =
    { pkgs, ... }:
    {
      environment = {
        variables = {
          EDITOR = "nvim";
          TERMINAL = "kitty";
        };
        systemPackages = with pkgs; [
          git
          vim
          wget
          curl
          btop
          ripgrep
          fd
          eza
          tree
          htop
          zip
          unzip
          jq
        ];
      };
    };

  flake.modules.darwin.environment =
    { pkgs, ... }:
    {
      environment = {
        variables = {
          EDITOR = "nvim";
          TERMINAL = "kitty";
        };
        systemPackages = with pkgs; [
          git
          vim
          wget
          curl
          btop
          ripgrep
          fd
          eza
          tree
          htop
          zip
          unzip
          jq
        ];
      };
    };

  flake.modules.homeManager.environment = {
    home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "kitty";
    };
    home.profileExtra = ''
      if [ -f "$HOME/.config/env.local" ]; then
        . "$HOME/.config/env.local"
      fi
    '';
  };
}
