{ ... }:
{
  imports = [
    ./core.nix
    ./keymaps.nix
    ./plugins
  ];

  config = {
    viAlias = true;
    vimAlias = true;
  };
}
