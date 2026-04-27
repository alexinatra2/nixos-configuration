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

      nix.enable = false;

      nixpkgs.config.allowUnfree = true;

      security.pam.services.sudo_local.touchIdAuth = true;

      homebrew = {
        enable = false;
        onActivation.cleanup = "zap";
      };

      system.stateVersion = 5;
    };
}
