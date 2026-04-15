{
  self,
  inputs,
  ...
}:
let
  hostKey = "wb-mac";
  hostname = "MacBook-Pro-von-Alexander";
  username = "alexanderholzknecht";
in
{
  flake.darwinModules.${hostKey} =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = with self.darwinModules; [
        packages
        systemSettings
        shortcuts
      ];

      networking.hostName = hostname;
      system.primaryUser = username;

      environment.variables = {
        EDITOR = "nvim";
        TERMINAL = "kitty";
      };

      # Determinate manages the Nix installation/daemon on macOS.
      # Disable nix-darwin's native Nix management to avoid activation aborts.
      nix.enable = false;

      nixpkgs.config.allowUnfree = true;

      # Homebrew integration (optional; requires Homebrew installed separately).
      homebrew = {
        enable = false;
        onActivation.cleanup = "zap";
      };

      system.stateVersion = 5;
    };
}
