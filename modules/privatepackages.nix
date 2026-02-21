{
  pkgs,
  ...
}:
{
  imports = [
    # ../home/xremap.nix
  ];

  home.packages = with pkgs; [
    eduvpn-client
    jetbrains.rust-rover
    ollama
    qgis
  ];
}
