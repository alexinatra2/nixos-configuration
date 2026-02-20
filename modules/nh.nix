{
  flake.modules.nixos.nh =
    { username, ... }:
    {
      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          extraArgs = "--keep-since 4 --keep 3";
        };
        flake = "/home/${username}/nixos-configuration";
      };
    };

  flake.modules.homeManager.nh =
    { username, ... }:
    {
      # Enable nh for home-manager
      programs.nh = {
        enable = true;
        flake = "/home/${username}/nixos-configuration";
        clean.enable = true;
      };
    };
}
