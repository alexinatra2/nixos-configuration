{
  flake.modules.nixos.gaming = {
    # Nix-ld for running non-Nix binaries
    programs.nix-ld = {
      enable = true;
      libraries = [ ];
    };

    # Steam gaming
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    # Game optimization
    programs.gamemode.enable = true;

    # Environment variable for Steam compatibility tools
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/alexander/.steam/root/compatibilitytools.d";
    };
  };

}
