# Environment configuration for all platforms
{ ... }:
let
  commonEnvVars = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
  };

  commonPackages =
    pkgs: with pkgs; [
      git
      vim
      wget
      curl
      btop
      ripgrep
      fd
      eza
    ];

  devPackages =
    pkgs: with pkgs; [
      tree
      htop
      zip
      unzip
      jq
    ];
in
{
  flake.modules.nixos.environment =
    { pkgs, ... }:
    {
      environment.variables = commonEnvVars;
      environment.systemPackages = commonPackages pkgs ++ devPackages pkgs;
    };

  flake.modules.darwin.environment =
    { pkgs, ... }:
    {
      environment.variables = commonEnvVars;
      environment.systemPackages = commonPackages pkgs ++ devPackages pkgs;
    };

  flake.modules.homeManager.environment = {
    home.sessionVariables = commonEnvVars;
  };
}
