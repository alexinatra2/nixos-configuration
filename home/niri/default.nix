{
  inputs,
  ...
}:

{
  imports = [
    inputs.niri.homeModules.niri
    ./settings.nix
    ./keymaps.nix
  ];

  programs.niri.enable = true;
}
