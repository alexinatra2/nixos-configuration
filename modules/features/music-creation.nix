{ self, inputs, ... }:
{
  flake.modules.homeManager.music-creation = { pkgs, ... }: {
    home.packages = with pkgs; [
      ardour
      audacity
      zrythm
    ];
  };
}
