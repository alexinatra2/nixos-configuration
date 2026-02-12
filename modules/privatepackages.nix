{
  pkgs,
  ...
}:
{
  imports = [
    ../home/xremap.nix
  ];

  home.packages = with pkgs; [
    discord
    eduvpn-client
    jetbrains.rust-rover
    ollama
    qgis
  ];
}
