{
  flake.modules.homeManager.kitty =
    { lib, ... }:
    {
      programs.kitty = lib.mkForce {
        enable = true;
        settings = {
          background_opacity = "0.9";
        };
      };
    };
}
